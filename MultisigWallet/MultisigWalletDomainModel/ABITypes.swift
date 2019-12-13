//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

// MARK: - Introduction

// We declare a set of types that are used in Solidity contracts so that our contract interaction
// reads naturally in Swift.
//
// The integer types are either wrappers around Swift integer types, or around BigInt if they do not fit into
// standard type system.

// MARK: - SOLUnsignedBinaryInteger

// Allows to implement encoding and decoding algorithms in a generic way
protocol SOLUnsignedBinaryInteger {

    /// Number of bits in the integer
    static var bitWidth: Int { get }

    /// Type used as a 'base' for encoding
    associatedtype Word: SOLUnsignedBinaryInteger

    /// Swift type of integer's value
    associatedtype Storage: BinaryInteger

    /// Integer value as a Swift type
    var value: Storage { get }

    /// Right bit-shift operator
    static func >> (lhs: Self, rhs: Int) -> Self

    /// Bitwise AND operator
    static func & (lhs: Self, rhs: Int) -> Self

}

/// Allows to initialize any Swift Int/UInt with a SOL-integer
extension FixedWidthInteger {

    /// Create an integer from a Solidity integer.
    ///
    /// NOTE: If the value does not fit into the `FixedWidthInteger`, then this results in runtime error.
    init<T>(_ value: T) where T: SOLUnsignedBinaryInteger {
        self.init(value.value)
    }

}

// MARK: - SOLUInt8

/// Solidity UInt8 unsigned integer type.
struct SOLUInt8 {

    let value: UInt8

    init(_ value: UInt8) {
        self.value = value
    }

    init(_ value: Int) {
        self.init(UInt8(value))
    }

}

extension SOLUInt8: ExpressibleByIntegerLiteral {

    init(integerLiteral value: UInt8) {
        self.init(value)
    }

}

extension SOLUInt8: ABIEncodable {

    func encode(to encoder: ABIEncoder) throws {
        try encoder.encode(self)
    }

}

extension SOLUInt8: SOLUnsignedBinaryInteger {

    typealias Word = SOLUInt256

    typealias Storage = UInt8

    static var bitWidth: Int { return 8 }

    static func >> (lhs: SOLUInt8, rhs: Int) -> SOLUInt8 {
        SOLUInt8(lhs.value >> rhs)
    }

    static func & (lhs: SOLUInt8, rhs: Int) -> SOLUInt8 {
        SOLUInt8(lhs.value & UInt8(rhs))
    }

}

// MARK: - SOLUInt256

struct SOLUInt256 {

    let value: BigInt

    init(_ value: BigInt) {
        self.value = value
    }

}

extension SOLUInt256: SOLUnsignedBinaryInteger {

    static var bitWidth: Int { return 256 }

    typealias Word = SOLUInt256

    typealias Storage = BigInt

    static func >> (lhs: SOLUInt256, rhs: Int) -> SOLUInt256 {
        preconditionFailure("implement") // TODO
    }

    static func & (lhs: SOLUInt256, rhs: Int) -> SOLUInt256 {
        preconditionFailure("implement") // TODO
    }

}

typealias SOLUInt = SOLUInt256

// MARK: - Not Implemented Yet

// MARK: SOLUInt160 & SOLAddress

struct SOLUInt160 {

    let value: BigInt

}

extension SOLUInt160: SOLUnsignedBinaryInteger {

    static var bitWidth: Int { return 160 }

    typealias Word = SOLUInt256

    static func >> (lhs: SOLUInt160, rhs: Int) -> SOLUInt160 {
        preconditionFailure("implement") // TODO
    }

    static func & (lhs: SOLUInt160, rhs: Int) -> SOLUInt160 {
        preconditionFailure("implement") // TODO
    }

}

typealias SOLAddress = SOLUInt160

extension SOLAddress {

    init(_ value: Address) {
        preconditionFailure("implement") // TODO
    }
}

struct SOLBool {}

struct SOLBytes32 {}

struct SOLBytes {

    init(_ value: Data) {}
}

struct SOLArray<T> {}

struct SOLString {}

struct SOLTuple {

    init(_ values: Any...) {}
}

struct SOLFunctionCall {

    var argumentsData: Data {
        preconditionFailure()
    }

    init(selector: String, arguments: ABIEncodable...) {}

    func isSelector(_ value: String) -> Bool {
        return false
    }
}

struct SOLSelector {

    init(_ value: String) {}
}

extension Int {

    init(_ value: SOLUInt8) {
        self = 0
    }
}

extension Address {

    init(_ value: SOLAddress) {
        self.init("")
    }
}

extension BigInt {

    init(_ value: SOLUInt256) {
        self.init(0)
    }
}

extension Data {

    init(_ value: SOLBytes) {
        self.init([])
    }
}
