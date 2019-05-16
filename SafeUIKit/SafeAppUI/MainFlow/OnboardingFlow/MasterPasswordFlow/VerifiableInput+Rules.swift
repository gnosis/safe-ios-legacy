//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import SafeUIKit

extension VerifiableInput {

    enum Strings {
        static let length = LocalizedString("new_password_min_chars", comment: "Use a minimum of 8 characters.")
        static let letterAndDigit = LocalizedString("password_validation_one_number_one_letter",
                                                    comment: "At least 1 digit and 1 letter.")
        static let trippleChars = LocalizedString("password_validation_identical_characters",
                                                  comment: "No triple characters.")
        static let matchPassword = LocalizedString("passwords_do_not_match", comment: "Passwords must match.")
    }

    func configureForNewPassword() {
        configurePasswordAppearance()
        textInput.showSuccessIndicator = false
        self.addRule(Strings.length) {
            PasswordValidator.validateMinLength($0)
        }
        addRule(Strings.letterAndDigit) {
            PasswordValidator.validateAtLeastOneLetterAndOneDigit($0)
        }
        addRule(Strings.trippleChars) {
            PasswordValidator.validateNoTrippleChar($0)
        }
    }

    func configureForConfirmPassword(referencePassword: String) {
        configurePasswordAppearance()
        showErrorsOnly = true
        adjustsHeightForHiddenRules = true
        addRule(Strings.matchPassword) {
            PasswordValidator.validate(input: $0, equals: referencePassword)
        }
    }

    func configurePasswordAppearance() {
        isSecure = true
        returnKeyType = .next
        style = .white
        returnKeyType = .next
    }

}
