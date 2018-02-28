//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

extension String {

    func containsCapitalLetter() -> Bool {
        return rangeOfCharacter(from: CharacterSet.uppercaseLetters) != nil
    }

    func containsDigit() -> Bool {
        return rangeOfCharacter(from: CharacterSet.decimalDigits) != nil
    }

}
