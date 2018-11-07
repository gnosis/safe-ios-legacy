//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

extension String {

    func containsLetter() -> Bool {
        return rangeOfCharacter(from: CharacterSet.letters) != nil
    }

    func containsDigit() -> Bool {
        return rangeOfCharacter(from: CharacterSet.decimalDigits) != nil
    }

    func noTrippleChar() -> Bool {
        guard count > 2 else { return true }
        var current = self.first!
        var longestSiquence = 1
        for c in suffix(count - 1) {
            if c == current {
                longestSiquence += 1
                guard longestSiquence < 3 else { return false }
            } else {
                current = c
                longestSiquence = 1
            }
        }
        return true
    }

}
