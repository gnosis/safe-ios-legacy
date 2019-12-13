//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

// MultiSend contract allows to atomically execute many transactions in just one ABI call.
//
// There are 2 versions of the contract that were used with safe contracts:
//      - v1: https://github.com/gnosis/safe-contracts/blob/v1.0.0/contracts/libraries/MultiSend.sol
//      - v2: https://github.com/gnosis/safe-contracts/blob/v1.1.0/contracts/libraries/MultiSend.sol
//
// Since multiple versions were used, some old transactions might still have data that we want to show.
// Therefore, we need to maintain encoding and decoding algorithms for each version.
//
// The v1 uses standard Solidity contract ABI encoding, and v2 uses non-standard packed encoding.
// Both defined in specs: https://solidity.readthedocs.io/en/v0.5.14/abi-spec.html#non-standard-packed-mode
//
// The `MultiSendContract` is using a Factory Method approach to select proper encoding based on
// the contract address. The mapping between contract addresses and version numbers is provided from
// `SafeContractMetadataRepospitory`.
//
// The encoding and decoding of ABI function calls is via `ABIEncodable` and `ABIDecodable` adoption.
// The function call is represented by a `MultiSendCall` struct.
class MultiSendContract {

    let address: Address
    private let codableFactory: ABICodableFactory

    init(_ address: Address) {
        self.address = address
        self.codableFactory = MultiSendContract.codableFactory(from: address)
    }

    func multiSend(_ transactions: [MultiSendTx]) -> Data {
        let functionCall = MultiSendFunctionCall(transactions: transactions)
        let encoder = codableFactory.createEncoder()
        return try! encoder.encode(functionCall)
    }

    func decodeMultiSend(_ data: Data) -> [MultiSendTx]? {
        let decoder = codableFactory.createDecoder()
        let functionCall = try? decoder.decode(MultiSendFunctionCall.self, from: data)
        return functionCall?.transactions
    }

    // Switches between different contract verseions
    private class func codableFactory(from address: Address) -> ABICodableFactory {
        let version = DomainRegistry.safeContractMetadataRepository.version(multiSendAddress: address)
        switch version {
        case .some(1):
            return ContractV1()
        default:
            return ContractV2()
        }
    }

    private class ContractV1: ABICodableFactory {
        func createEncoder() -> ABIEncoder {
            StandardABIEncoder()
        }
        func createDecoder() -> ABIDecoder {
            StandardABIDecoder()
        }
    }

    private class ContractV2: ABICodableFactory {
        func createEncoder() -> ABIEncoder {
            PackedABIEncoder()
        }
        func createDecoder() -> ABIDecoder {
            PackedABIDecoder()
        }
    }

}


// This factory interface allows to switch between encoders at runtime
fileprivate protocol ABICodableFactory {

    func createEncoder() -> ABIEncoder
    func createDecoder() -> ABIDecoder

}

fileprivate struct MultiSendFunctionCall {

    let selector = "multiSend(bytes)"
    var transactions: [MultiSendTx]

}

extension MultiSendFunctionCall: ABIEncodable {

    func encode(to encoder: ABIEncoder) throws {
        let call = SOLFunctionCall(selector: selector, arguments: transactions)
        try encoder.encode(call)
    }

}

extension MultiSendFunctionCall: ABIDecodable {

    init(from decoder: ABIDecoder) throws {
        let call = try decoder.decode(SOLFunctionCall.self)
        guard call.isSelector(selector) else {
            throw ABIDecodingError.unexpectedFunctionCallSelector
        }
        transactions = try decoder.decode([MultiSendTx].self, from: call.argumentsData)
    }

}
