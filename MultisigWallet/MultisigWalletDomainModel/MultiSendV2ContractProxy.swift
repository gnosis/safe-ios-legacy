//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

public class MultiSendV2ContractProxy: MultiSendContractProxy {

    public override func multiSend(_ transactions: [MultiSendTransaction]) -> Data {
        let argumentData = transactions.reduce(into: Data()) { result, tx in
            result.append(encodeUInt8(UInt8(tx.operation.rawValue)))
            result.append(encodeAddress(tx.to))
            result.append(encodeUInt256(abs(tx.value)))
            let bytes = encodeBytes(tx.data)
            result.append(encodeUInt256(bytes.count))
            result.append(bytes)
        }
        let bytesOffsetInInvocation = 32
        return invocation(MultiSendContractProxy.multiSendSignature,
                          // super.encodeBytes is not packed encoding
                          encodeUInt(bytesOffsetInInvocation) + super.encodeBytes(argumentData))
    }

    public override func decodeMultiSendArguments(from data: Data) -> [MultiSendTransaction]? {
        let selector = method(MultiSendContractProxy.multiSendSignature)
        guard data.starts(with: selector) else { return nil }
        var input = data
        input.removeFirst(selector.count)
        let uint256ByteCount = 32
        let uint8ByteCount = 1
        let addressByteCount = 20
        /* bytesOffset of the argument */ input.removeFirst(uint256ByteCount)
        var bytes = decodeBytes(input)

        var result = [MultiSendTransaction]()

        while !bytes.isEmpty {
            let operation = decodeUInt8(bytes); bytes.removeFirst(uint8ByteCount)
            guard let txOperation = MultiSendTransactionOperation(rawValue: Int(operation)) else {
                return nil
            }

            let to = decodeAddress(bytes); bytes.removeFirst(addressByteCount)
            let value = decodeUInt256(bytes); bytes.removeFirst(uint256ByteCount)
            let length = decodeUInt256(bytes); bytes.removeFirst(uint256ByteCount)
            let data = decodeBytes(bytes, count: Int(length)); bytes.removeFirst(Int(length))

            result.append((txOperation, to, BigInt(value), data))
        }
        return result
    }

    public override func encodeAddress(_ value: Address) -> Data {
        Data(ethHex: value.value).leftPadded(to: 20).suffix(20)
    }

    override func decodeAddress(_ value: Data) -> Address {
        let bigEndianValue = value.count > 20 ? value.prefix(20) : value
        return Address(BigUInt(bigEndianValue))
    }

    func encodeUInt256(_ value: Int) -> Data {
        encodeUInt(BigInt(value))
    }

    func encodeUInt256(_ value: BigInt) -> Data {
        super.encodeUInt(value)
    }

    func decodeUInt256(_ value: Data) -> BigUInt {
        super.decodeUInt(value)
    }

    func encodeUInt8(_ value: UInt8) -> Data {
        Data(ethHex: String(value, radix: 16)).leftPadded(to: 1).suffix(1)
    }

    func decodeUInt8(_ value: Data) -> UInt8 {
        let bigEndianValue = value.count > 1 ? value.prefix(1) : value
        return UInt8(BigUInt(bigEndianValue))
    }

    override func encodeBytes(_ value: Data) -> Data {
        value
    }

    func decodeBytes(_ value: Data, count: Int) -> Data {
        return value.prefix(Int(count))
    }
}
