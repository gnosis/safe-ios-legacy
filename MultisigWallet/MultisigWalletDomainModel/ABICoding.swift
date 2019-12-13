//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

protocol ABIEncodable {

    func encode(to encoder: ABIEncoder) throws

}

protocol ABIEncoder: class {

    func encode(_ value: SOLUInt8) throws
    func encode(_ value: SOLUInt256) throws
    func encode(_ value: SOLAddress) throws
    func encode(_ value: SOLBytes) throws
    func encode(_ value: SOLSelector) throws
    func encode(_ value: SOLFunctionCall) throws
    func encode(_ value: SOLTuple) throws
    func encode<T>(value: T) throws where T: ABIEncodable

    func encode<T>(_ value: T) throws -> Data where T: ABIEncodable
}


protocol ABIDecodable {

    init(from decoder: ABIDecoder) throws

}

protocol ABIDecoder: class {

    func decode(_ type: SOLUInt8.Type) throws -> SOLUInt8
    func decode(_ type: SOLUInt256.Type) throws -> SOLUInt256
    func decode(_ type: SOLAddress.Type) throws -> SOLAddress
    func decode(_ type: SOLBytes.Type) throws -> SOLBytes
    func decode(_ type: SOLSelector.Type) throws -> SOLSelector
    func decode(_ type: SOLFunctionCall.Type) throws -> SOLFunctionCall
    func decode(_ type: SOLTuple.Type) throws -> SOLTuple
    func decode<T>(type: T.Type) throws -> T where T: ABIDecodable

    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: ABIDecodable

    var isAtEnd: Bool { get }
}

enum ABIDecodingError: Error {
    case unexpectedFunctionCallSelector
    case unexpectedValue
}
