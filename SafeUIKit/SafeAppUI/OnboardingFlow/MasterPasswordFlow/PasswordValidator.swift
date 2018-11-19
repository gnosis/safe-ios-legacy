//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

final class PasswordValidator {

    static let minInputLength = 8

    static func validateMinLength(_ input: String) -> Bool {
        return input.count >= minInputLength
    }

    static func validateAtLeastOneLetterAndOneDigit(_ input: String) -> Bool {
        return input.hasLetter && input.hasDecimalDigit
    }

    static func validateNoTrippleChar(_ input: String) -> Bool {
        return !input.isEmpty && input.hasNoTrippleChar
    }

    static func validate(input: String, equals other: String) -> Bool {
        return input == other
    }

}
