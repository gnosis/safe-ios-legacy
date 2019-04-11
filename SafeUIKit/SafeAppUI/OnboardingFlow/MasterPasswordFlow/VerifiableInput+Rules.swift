//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import SafeUIKit

extension VerifiableInput {

    enum Strings {
        static let length = LocalizedString("onboarding.set_password.length",
                                            comment: "Use a minimum of 8 characters.")
        static let letterAndDigit = LocalizedString("onboarding.set_password.letter_and_digit",
                                                    comment: "At least 1 digit and 1 letter.")
        static let trippleChars = LocalizedString("onboarding.set_password.no_tripple_chars",
                                                  comment: "No triple characters.")

        static let matchPassword = LocalizedString("onboarding.confirm_password.match",
                                                   comment: "Passwords must match.")
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
