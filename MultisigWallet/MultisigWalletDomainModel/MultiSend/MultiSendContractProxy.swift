//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

public enum MultiSendTransactionOperation: Int {
    case call = 0
    case delegateCall = 1
}

public typealias MultiSendTransaction =
    (operation: MultiSendTransactionOperation, to: Address, value: BigInt, data: Data)

public class MultiSendContractProxy: EthereumContractProxy {

    static let multiSendSignature = "multiSend(bytes)"
    private let implementation: MultiSendContract

    public static func isMultiSend(_ address: Address) -> Bool {
        return DomainRegistry.safeContractMetadataRepository.isValidMultiSend(address: address)
    }

    public override init(_ contract: Address) {
        let address = contract == .zero ?
            DomainRegistry.safeContractMetadataRepository.multiSendContractAddress : contract
        let version = DomainRegistry.safeContractMetadataRepository.version(multiSendAddress: address)
        switch version {
        case 1:
            implementation = MultiSendContractV1(address)
        default:
            implementation = MultiSendContractV2(address)
        }
        super.init(address)
    }

    public func multiSend(_ transactions: [MultiSendTransaction]) -> Data {
        implementation.multiSend(transactions)
    }

    public func decodeMultiSendArguments(from data: Data) -> [MultiSendTransaction]? {
        implementation.decodeMultiSendArguments(from: data)
    }

}

protocol MultiSendContract {

    func multiSend(_ transactions: [MultiSendTransaction]) -> Data
    func decodeMultiSendArguments(from data: Data) -> [MultiSendTransaction]?

}
