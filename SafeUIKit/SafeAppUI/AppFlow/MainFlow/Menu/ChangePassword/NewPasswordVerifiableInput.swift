//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import SafeUIKit

// TODO: delete
final class NewPasswordVerifiableInput: VerifiableInput {

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
