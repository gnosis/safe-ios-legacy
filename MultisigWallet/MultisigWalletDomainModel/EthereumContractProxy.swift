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
        let bigEndianValue = value.prefix(32)
        return BigUInt(bigEndianValue)
    }

    func decodeArrayUInt(_ value: Data) -> [BigUInt] {
        let count = decodeUInt(value)
        return decodeTupleUInt(value.suffix(from: 32), Int(count))
    }

    func encodeArrayUInt(_ value: [BigUInt]) -> Data {
        return encodeUInt(BigUInt(value.count)) + encodeTupleUInt(value)
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
