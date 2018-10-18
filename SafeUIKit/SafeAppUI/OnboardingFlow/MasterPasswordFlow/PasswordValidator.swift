//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

final class PasswordValidator {

    static let minInputLength = 8

    static func validateMinLength(_ input: String) -> Bool {
        return input.count >= minInputLength
    }

    static func validateAtLeastOneCapitalLetterAndOneDigit(_ input: String) -> Bool {
        return input.containsCapitalLetter() && input.containsDigit()
    }

    static func validateNoTrippleChar(_ input: String) -> Bool {
        return input.noTrippleChar()
    }

    static func validate(input: String, equals other: String) -> Bool {
        return input == other
    }

}
