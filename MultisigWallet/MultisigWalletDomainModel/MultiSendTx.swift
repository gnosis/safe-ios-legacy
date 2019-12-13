//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

struct MultiSendTx {

    var operation: Operation
    var to: Address
    var value: BigInt
    var data: Data

    enum Operation: Int {
        // if there is another contract function call inside `data`, it will be called as a normal call-return.
        case call = 0
        // if there is another contract function call inside `data`, then that code will be dynamically loaded
        // and executed within context of the `multiSend()` function of the `MultiSend` smart contract.
        case delegateCall = 1
    }

}

extension MultiSendTx: ABIEncodable {

    func encode(to encoder: ABIEncoder) throws {
        try encoder.encode(
            SOLTuple(
                SOLUInt8(operation.rawValue),
                SOLAddress(to),
                SOLUInt256(value),
                SOLBytes(data)
            )
        )
    }

}

extension MultiSendTx: ABIDecodable {

    init(from decoder: ABIDecoder) throws {
        let operationRawValue = try decoder.decode(SOLUInt8.self)

        guard let operation = Operation(rawValue: Int(operationRawValue)) else {
            throw ABIDecodingError.unexpectedValue
        }

        self.operation = operation
        self.to = try Address(decoder.decode(SOLAddress.self))
        self.value = try BigInt(decoder.decode(SOLUInt256.self))
        self.data = try Data(decoder.decode(SOLBytes.self))
    }

}

// MARK: - [MultiSendTx]

extension Array: ABIEncodable where Element == MultiSendTx {

    func encode(to encoder: ABIEncoder) throws {
        for tx in self {
            try encoder.encode(value: tx)
        }
    }

}

extension Array: ABIDecodable where Element == MultiSendTx {

    init(from decoder: ABIDecoder) throws {
        var result: [MultiSendTx] = []
        while !decoder.isAtEnd {
            let transaction = try decoder.decode(type: MultiSendTx.self)
            result.append(transaction)
        }
        self = result
    }

}
