//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

// https://solidity.readthedocs.io/en/v0.5.14/abi-spec.html

class StandardABIEncoder: ABIEncoder {

    private var container: Data = Data()

    // Encodes SOLUInt<N> value to a binary container
    func encode<T>(_ value: T) throws where T: SOLUnsignedBinaryInteger {
        assert(T.bitWidth <= T.Word.bitWidth)

        // 1. Encode integer value to Big-endian encoding
        let sizeOfValueInBytes = T.bitWidth / 8
        let bigEndianByteSequence = (0..<sizeOfValueInBytes).reversed()

        let valueAsBytes = bigEndianByteSequence.map { byteIndex -> UInt8 in
            let bitsToShift = byteIndex * 8
            return UInt8(value >> bitsToShift & 0xFF)
        }

        // 2. Pad with 0 bytes to the Word size
        let bytesInWord = T.Word.bitWidth / 8
        let padding = Data(repeating: 0, count: bytesInWord - valueAsBytes.count)
        let encoded = padding + Data(valueAsBytes)

        assert(encoded.count == bytesInWord)
        container.append(encoded)
    }

    func encode(_ value: SOLBytes) throws {
        // TODO: implement
    }

    func encode(_ value: SOLSelector) throws {
        // TODO: implement
    }

    func encode(_ value: SOLFunctionCall) throws {
        // TODO: implement
    }

    func encode(_ value: SOLTuple) throws {
        // TODO: implement
    }

    func encode<T>(value: T) throws where T : ABIEncodable {
        // TODO: implement
    }

    func encode<T>(_ value: T) throws -> Data where T : ABIEncodable {
        try value.encode(to: self)
        return container
        preconditionFailure("not implemented")
    }

}

class StandardABIDecoder: ABIDecoder {

    func decode(_ type: SOLUInt8.Type) throws -> SOLUInt8 {
        preconditionFailure("implement")    }

    func decode(_ type: SOLUInt256.Type) throws -> SOLUInt256 {
        preconditionFailure("implement")    }

    func decode(_ type: SOLAddress.Type) throws -> SOLAddress {
        preconditionFailure("implement")
    }

    func decode(_ type: SOLBytes.Type) throws -> SOLBytes {
        preconditionFailure("implement")    }

    func decode(_ type: SOLSelector.Type) throws -> SOLSelector {
        preconditionFailure("implement")    }

    func decode(_ type: SOLFunctionCall.Type) throws -> SOLFunctionCall {
        preconditionFailure("implement")    }

    func decode(_ type: SOLTuple.Type) throws -> SOLTuple {
        preconditionFailure("implement")    }

    func decode<T>(type: T.Type) throws -> T where T : ABIDecodable {
        preconditionFailure("implement")
    }

    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : ABIDecodable {
        preconditionFailure("implement")
    }

    var isAtEnd: Bool {
        preconditionFailure("implement")
    }


}
