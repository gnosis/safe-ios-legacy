//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

public class EthereumContractProxy {

    var nodeService: EthereumNodeDomainService { return DomainRegistry.ethereumNodeService }
    var encryptionService: EncryptionDomainService { return DomainRegistry.encryptionService }

    func method(_ selector: String) -> Data {
        return encryptionService.hash(selector.data(using: .ascii)!).prefix(4)
    }

    func encodeUInt(_ value: BigUInt) -> Data {
        return Data(ethHex: String(value, radix: 16)).leftPadded(to: 32).suffix(32)
    }

    func decodeUInt(_ value: Data) -> BigUInt {
        let bigEndianValue = value[value.startIndex..<value.startIndex + 32]
        return BigUInt(bigEndianValue)
    }

    /// NOTE: resulting address is NOT formatted according to EIP-55
    func decodeAddress(_ value: Data) -> Address {
        let uintValue = decodeUInt(value)
        return Address(uintValue)
    }

    func encodeAddress(_ value: Address) -> Data {
        return encodeUInt(BigUInt(Data(ethHex: value.value)))
    }

    func decodeArrayUInt(_ value: Data) -> [BigUInt] {
        let offset = decodeUInt(value)
        let data = value[Int(offset)..<value.endIndex]
        let count = decodeUInt(data)
        return decodeTupleUInt(data[data.startIndex + 32..<data.endIndex], Int(count))
    }

    func encodeArrayUInt(_ value: [BigUInt]) -> Data {
        return encodeUInt(32) + encodeUInt(BigUInt(value.count)) + encodeTupleUInt(value)
    }

    func encodeArrayAddress(_ value: [Address]) -> Data {
        return encodeArrayUInt(value.map { BigUInt(Data(ethHex: $0.value)) })
    }

    func decodeArrayAddress(_ value: Data) -> [Address] {
        return decodeArrayUInt(value).map { Address($0) }
    }

    func decodeTupleUInt(_ value: Data, _ count: Int) -> [BigUInt] {
        let rawValues = stride(from: value.startIndex, to: value.startIndex + count * 32, by: 32).map { i in
            value[i..<i + 32]
        }
        return rawValues.compactMap { decodeUInt($0) }
    }

    func encodeTupleUInt(_ value: [BigUInt]) -> Data {
        return (value.map { headUInt($0) } + value.map { tailUInt($0) }).reduce(into: Data()) { $0.append($1) }
    }

    func headUInt(_ value: BigUInt) -> Data {
        return encodeUInt(value)
    }

    func tailUInt(_ value: BigUInt) -> Data {
        return Data()
    }

}

fileprivate extension Address {

    init(_ value: BigUInt) {
        self.init("0x" + String(value, radix: 16))
    }

}
