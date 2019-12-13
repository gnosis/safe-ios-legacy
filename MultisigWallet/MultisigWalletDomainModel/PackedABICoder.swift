//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation


class PackedABIEncoder: ABIEncoder {
    func encode(_ value: SOLUInt8) throws {
        preconditionFailure("implement")
    }

    func encode(_ value: SOLUInt256) throws {
        preconditionFailure("implement")
    }

    func encode(_ value: SOLAddress) throws {
        preconditionFailure("implement")
    }

    func encode(_ value: SOLBytes) throws {
        preconditionFailure("implement")
    }

    func encode(_ value: SOLSelector) throws {
        preconditionFailure("implement")
    }

    func encode(_ value: SOLFunctionCall) throws {
        preconditionFailure("implement")
    }

    func encode(_ value: SOLTuple) throws {
        preconditionFailure("implement")
    }

    func encode<T>(value: T) throws where T : ABIEncodable {
        preconditionFailure("implement")
    }

    func encode<T>(_ value: T) throws -> Data where T : ABIEncodable {
        preconditionFailure("implement")
    }


}

class PackedABIDecoder: ABIDecoder {
    func decode(_ type: SOLUInt8.Type) throws -> SOLUInt8 {
        preconditionFailure("implement")
    }

    func decode(_ type: SOLUInt256.Type) throws -> SOLUInt256 {
        preconditionFailure("implement")
    }

    func decode(_ type: SOLAddress.Type) throws -> SOLAddress {
        preconditionFailure("implement")
    }

    func decode(_ type: SOLBytes.Type) throws -> SOLBytes {
        preconditionFailure("implement")
    }

    func decode(_ type: SOLSelector.Type) throws -> SOLSelector {
        preconditionFailure("implement")
    }

    func decode(_ type: SOLFunctionCall.Type) throws -> SOLFunctionCall {
        preconditionFailure("implement")
    }

    func decode(_ type: SOLTuple.Type) throws -> SOLTuple {
        preconditionFailure("implement")
    }

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
