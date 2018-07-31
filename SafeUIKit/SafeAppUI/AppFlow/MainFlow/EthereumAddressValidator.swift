//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

class EthereumAddressValidator {

    enum ValidationError: Error, Equatable {
        case empty
        case invalidCharacter(Int)
        case valueTooShort(Int)
        case valueTooLong(Int)
        case zeroAddress

        static func ==(lhs: ValidationError, rhs: ValidationError) -> Bool {
            switch (lhs, rhs) {
            case (.empty, .empty), (.zeroAddress, .zeroAddress): return true
            case let (.valueTooShort(lcount), .valueTooShort(rcount)): return lcount == rcount
            case let (.valueTooLong(lcount), .valueTooLong(rcount)): return lcount == rcount
            case let (.invalidCharacter(lpos), .invalidCharacter(rpos)): return lpos == rpos
            default: return false
            }
        }
    }

    private let byteCount: Int
    private var charCount: Int { return byteCount * 2 }

    init(byteCount: Int) {
        self.byteCount = byteCount
    }

    func validate(_ address: String) -> ValidationError? {
        if address.isEmpty { return .empty }
        let value = address.lowercased()
        let unprefixed = value.hasPrefix("0x") ? String(value.dropFirst(2)) : value
        if unprefixed.count <= charCount && unprefixed.hasCharactersNotIn(.zeroDigit) { return .zeroAddress }
        if let offset = offsetOfNonHexChar(in: value) { return .invalidCharacter(offset) }
        if unprefixed.count < charCount { return .valueTooShort(unprefixed.count) }
        if unprefixed.count > charCount { return .valueTooLong(unprefixed.count) }
        return nil
    }

    private func offsetOfNonHexChar(in value: String) -> Int? {
        let startIndex = value.hasPrefix("0x")
            ? value.index(value.startIndex,
                          offsetBy: 2,
                          limitedBy: value.endIndex)
            : value.startIndex
        guard let start = startIndex,
            let index = value.index(charactersIn: CharacterSet.hexDigits.inverted, startIndex: start) else {
            return nil
        }
        return value.distance(from: value.startIndex, to: index)
    }
}

fileprivate extension CharacterSet {

    static let zeroDigit = CharacterSet(charactersIn: "0")
    static let hexDigits = CharacterSet(charactersIn: "0123456789abcdef")

}

fileprivate extension String {

    func hasCharactersNotIn(_ set: CharacterSet) -> Bool {
        return rangeOfCharacter(from: set.inverted) == nil
    }

    func index(charactersIn set: CharacterSet, startIndex: Index) -> Index? {
        return rangeOfCharacter(from: set, options: [], range: startIndex..<endIndex)?.lowerBound
    }

}
