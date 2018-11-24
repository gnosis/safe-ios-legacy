//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumKit
import BigInt
import Common

public class EthereumAddressFormatter {

    public init() {}

    // MARK: - Letter case

    /// Defines which letter case to use for hexadecimal digits.
    /// By default is `EthereumAddressFormatterHexMode.lowercased`
    public var hexMode: EthereumAddressFormatterHexMode = .lowercased

    // MARK: - Truncation

    /// Defines how to truncate the content
    public var truncationMode: EthereumAddressFormatterTruncationMode = .off
    /// Maximum number of characters after truncation. Ignored if `usesHeadTailSplit` is `true`
    public var maximumAddressLength: Int = 40
    /// Whether to truncate based on `headLength` and `tailLength`. Only useful for `middle` truncation mode.
    public var usesHeadTailSplit: Bool = false
    /// Number of address characters before truncation symbol
    public var headLength: Int = 20
    /// Number of address characters after truncation symbol
    public var tailLength: Int = 20
    /// Whether to add a hex prefix to the address
    public var usesHexPrefix: Bool = true

    // MARK: - Attributed string properties

    /// Attributes of a body part
    public var bodyAttributes: [NSAttributedString.Key: Any]?
    /// Attributes of a head part with length `[hexPrefixLength] + headLength`
    public var headAttributes: [NSAttributedString.Key: Any]?
    /// Attributes of a tail part length `tailLength`
    public var tailAttributes: [NSAttributedString.Key: Any]?
    /// Length of the hexadecimal prefix `0x`. Equals 2.
    public let hexPrefixLength: Int = 2

    /// Formats address as a String.
    ///
    /// The data will be truncated to 20 bytes length, or padded from the left to 20 bytes.
    ///
    /// - Parameter value: address as a data bytes
    /// - Returns: formatted address
    public func string(from value: Data) -> String {
        let hex = HexMode.create(hexMode)
        let truncate = TruncationMode.create(truncationMode)
        truncate.maximumAddressLength = maximumAddressLength
        truncate.usesHeadTailSplit = usesHeadTailSplit
        truncate.headLength = headLength
        truncate.tailLength = tailLength
        return prefixed(truncate.string(from: hex.string(from: value.endTruncated(to: 20).leftPadded(to: 20))))
    }

    public func string(from value: String) -> String {
        return string(from: data(from: value))
    }

    private func data(from value: String) -> Data {
        let string = value.stripHexPrefix()
        let isOdd = string.count % 2 == 1
        return Data(hex: isOdd ? string.paddingWithLeadingZeroes(to: string.count + 1) : string)
    }

    /// Formats address as an attributed string. See the `string(from:)` for details.
    ///
    /// - Parameter value: address
    /// - Returns: attributed string
    public func attributedString(from value: Data) -> NSAttributedString {
        let string = NSMutableAttributedString(string: self.string(from: value), attributes: bodyAttributes)
        let prefix = hexPrefixLength + headLength
        let suffix = tailLength
        assert(prefix + suffix <= string.length)
        if let headAttrs = headAttributes {
            string.addAttributes(headAttrs, range: NSRange(location: 0, length: prefix))
        }
        if let tailAttrs = tailAttributes {
            string.addAttributes(tailAttrs, range: NSRange(location: string.length - suffix, length: suffix))
        }
        return string.copy() as! NSAttributedString
    }

    public func attributedString(from value: String) -> NSAttributedString {
        return attributedString(from: data(from: value))
    }

    private func prefixed(_ value: String) -> String {
        return usesHexPrefix ? value.addHexPrefix() : value
    }

}

/// Mode of hexadecimal characters
public enum EthereumAddressFormatterHexMode {
    /// All hex characters uppercased
    case lowercased
    /// All hex characters lowercased
    case uppercased
    /// EIP-55 mixed case checksum
    case mixedcased
}

extension EthereumAddressFormatter {

    class HexMode {

        var mode: EthereumAddressFormatterHexMode { preconditionFailure("Not implemented") }

        static func create(_ mode: EthereumAddressFormatterHexMode) -> HexMode {
            switch mode {
            case .lowercased: return Lowercased()
            case .uppercased: return Uppercased()
            case .mixedcased: return MixedCased()
            }
        }

        func string(from value: Data) -> String {
            return value.toHexString()
        }

    }

    class Lowercased: HexMode {

        override var mode: EthereumAddressFormatterHexMode { return .lowercased }

        override func string(from value: Data) -> String {
            return super.string(from: value).lowercased()
        }

    }

    class Uppercased: HexMode {

        override var mode: EthereumAddressFormatterHexMode { return .uppercased }

        override func string(from value: Data) -> String {
            return super.string(from: value).uppercased()
        }

    }

    class MixedCased: HexMode {

        override var mode: EthereumAddressFormatterHexMode { return .uppercased }

        override func string(from value: Data) -> String {
            return EIP55.encode(value)
        }

    }

}

/// Mode of truncation
public enum EthereumAddressFormatterTruncationMode {
    /// No truncation
    case off
    /// Truncate from the head of the address to the `maximumAddressLength`
    case head
    /// Truncate from the tail of the address to the `maximumAddressLength`
    case tail
    /// Truncate in the middle of the address to the `maximumAddressLength`
    /// or to the `[hexPrefixLength] + headLength + 1 + tailLength` if `usesHeadTailSplit` is true.
    case middle
}

extension EthereumAddressFormatter {

    class TruncationMode {

        var mode: EthereumAddressFormatterTruncationMode { preconditionFailure("Not implemented") }
        var maximumAddressLength: Int = 40
        var ellipsisCharacter: String = "…"
        var usesHeadTailSplit: Bool = false
        var headLength: Int = 20
        var tailLength: Int = 20

        static func create(_ mode: EthereumAddressFormatterTruncationMode) -> TruncationMode {
            switch mode {
            case .off: return Off()
            case .head: return Head()
            case .tail: return Tail()
            case .middle: return Middle()
            }
        }

        func string(from value: String) -> String {
            assert(maximumAddressLength <= value.count)
            return value
        }

    }

    class Off: TruncationMode {

        override var mode: EthereumAddressFormatterTruncationMode { return .off }

    }

    class Head: TruncationMode {

        override var mode: EthereumAddressFormatterTruncationMode { return .head }

        override func string(from value: String) -> String {
            return ellipsisCharacter + super.string(from: value).suffix(maximumAddressLength - 1)
        }

    }

    class Tail: TruncationMode {

        override var mode: EthereumAddressFormatterTruncationMode { return .tail }

        override func string(from value: String) -> String {
            return super.string(from: value).prefix(maximumAddressLength - 1) + ellipsisCharacter
        }

    }

    class Middle: TruncationMode {

        override var mode: EthereumAddressFormatterTruncationMode { return .middle }

        override func string(from value: String) -> String {
            if usesHeadTailSplit {
                assert(headLength + tailLength < value.count)
                return String(value.prefix(headLength)) + ellipsisCharacter + value.suffix(tailLength)
            } else {
                let base = super.string(from: value)
                let prefix = maximumAddressLength / 2
                let suffix = maximumAddressLength - prefix - 1
                return String(base.prefix(prefix)) + ellipsisCharacter + base.suffix(suffix)
            }
        }

    }

}
