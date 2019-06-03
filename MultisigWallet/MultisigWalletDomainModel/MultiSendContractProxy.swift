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
    public func multiSend(_ transactions: [MultiSendTransaction]) -> Data {
        let bytesOffsetInTransaction = 4 * 32
        let argumentData = transactions.reduce(into: Data()) { result, tx in
            result.append(encodeUInt(tx.operation.rawValue))
            result.append(encodeAddress(tx.to))
            result.append(encodeUInt(abs(tx.value)))
            result.append(encodeUInt(bytesOffsetInTransaction))
            result.append(encodeBytes(tx.data))
        }
        let bytesOffsetInInvocation = 32
        return invocation(MultiSendContractProxy.multiSendSignature,
                          encodeUInt(bytesOffsetInInvocation) + encodeBytes(argumentData))
    }

    public func decodeMultiSendArguments(from data: Data) -> [MultiSendTransaction]? {
        let selector = method(MultiSendContractProxy.multiSendSignature)
        guard data.starts(with: selector) else { return nil }
        var input = data
        input.removeFirst(selector.count)
        let uint256ByteCount = 32
        /* bytesOffset */ input.removeFirst(uint256ByteCount)
        var bytes = decodeBytes(input)

        var result = [MultiSendTransaction]()

        while !bytes.isEmpty {
            let operation = decodeUInt(bytes); bytes.removeFirst(uint256ByteCount)
            guard let txOperation = MultiSendTransactionOperation(rawValue: Int(operation)) else {
                return nil
            }

            let to = decodeAddress(bytes); bytes.removeFirst(uint256ByteCount)
            let value = decodeUInt(bytes); bytes.removeFirst(uint256ByteCount)
            /* tx data bytes offset */ bytes.removeFirst(uint256ByteCount)
            let data = decodeBytes(bytes); bytes.removeFirst(encodeBytes(data).count)

            result.append((txOperation, to, BigInt(value), data))
        }
        return result
    }

}
