//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import SafeUIKit

final class NewPasswordVerifiableInput: VerifiableInput {

    enum Strings {
        static let length = LocalizedString("onboarding.set_password.length",
                                            comment: "Use a minimum of 8 characters.")
        static let letterAndDigit = LocalizedString("onboarding.set_password.letter_and_digit",
                                                    comment: "At least 1 digit and 1 letter.")
        static let trippleChars = LocalizedString("onboarding.set_password.no_tripple_chars",
                                                  comment: "No triple characters.")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    private func commonInit() {
        isSecure = true
        returnKeyType = .next
        textInput.showSuccessIndicator = false
        addRule(Strings.length) {
            PasswordValidator.validateMinLength($0)
        }
        addRule(Strings.letterAndDigit) {
            PasswordValidator.validateAtLeastOneLetterAndOneDigit($0)
        }
        addRule(Strings.trippleChars) {
            PasswordValidator.validateNoTrippleChar($0)
        }
    }

}
