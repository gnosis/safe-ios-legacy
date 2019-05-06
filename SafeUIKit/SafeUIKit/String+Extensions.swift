//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

extension String {

    var removingTrailingZeroes: String {
        var result = self
        while result.last == "0" {
            result.removeLast()
        }
        return result
    }

    var removingLeadingZeroes: String {
        var result = self
        while result.first == "0" {
            result.removeFirst()
        }
        return result
    }

    var hasNonDecimalDigitCharacters: Bool {
        return rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil
    }

    func paddingWithTrailingZeroes(to width: Int) -> String {
        return self + String(repeating: "0", count: width - self.count)
    }

    func paddingWithLeadingZeroes(to width: Int) -> String {
        return String(repeating: "0", count: width - self.count) + self
    }

    func integerPart(_ decimals: Int) -> String {
        return String(prefix(count - decimals))
    }

    func fractionalPart(_ decimals: Int) -> String {
        return String(suffix(decimals))
    }

}
