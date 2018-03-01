//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

final class PasswordValidator {

    static let minInputLength = 6

    static func validateMinLength(_ input: String) -> Bool {
        return input.count >= minInputLength
    }

    static func validateAtLeastOneCapitalLetter(_ input: String) -> Bool {
        return input.containsCapitalLetter()
    }

    static func validateAtLeastOneDigit(_ input: String) -> Bool {
        return input.containsDigit()
    }

}
