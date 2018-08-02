//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

class EthereumAddressValidator: Validator {

    enum ValidationError: Error, Equatable {
        case empty
        case invalidCharacter(String, Int)
        case valueTooShort(Int, Int)
        case valueTooLong(Int, Int)
        case zeroAddress

        static func ==(lhs: ValidationError, rhs: ValidationError) -> Bool {
            switch (lhs, rhs) {
            case (.empty, .empty), (.zeroAddress, .zeroAddress): return true
            case let (.valueTooShort(lcount, lrequired), .valueTooShort(rcount, rrequired)):
                return lcount == rcount && lrequired == rrequired
            case let (.valueTooLong(lcount, lrequired), .valueTooLong(rcount, rrequired)):
                return lcount == rcount && lrequired == rrequired
            case let (.invalidCharacter(lchar, lpos), .invalidCharacter(rchar, rpos)):
                return lpos == rpos && lchar == rchar
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
        if unprefixed.count <= charCount && unprefixed.isAllCharacters(from: .zeroDigit) { return .zeroAddress }
        if let offset = offsetOfNonHexChar(in: value) {
            let character = String(value[value.index(value.startIndex, offsetBy: offset)])
            return .invalidCharacter(character, offset)
        }
        let requiredCount = value.hasPrefix("0x") ? charCount + 2 : charCount
        if value.count < requiredCount { return .valueTooShort(value.count, requiredCount) }
        if value.count > requiredCount { return .valueTooLong(value.count, requiredCount) }
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

    func isAllCharacters(from set: CharacterSet) -> Bool {
        return rangeOfCharacter(from: set.inverted) == nil
    }

    func index(charactersIn set: CharacterSet, startIndex: Index) -> Index? {
        return rangeOfCharacter(from: set, options: [], range: startIndex..<endIndex)?.lowerBound
    }

}
