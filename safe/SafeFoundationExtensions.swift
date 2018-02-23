//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

extension String {

    func containsCapitalizedLetter() -> Bool {
        return rangeOfCharacter(from: CharacterSet.uppercaseLetters) != nil
    }

    func containsDigit() -> Bool {
        // TODO: unit test
        return rangeOfCharacter(from: CharacterSet.decimalDigits) != nil
    }

}
