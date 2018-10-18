//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

protocol SetPasswordViewControllerDelegate: class {
    func didSetPassword(_ password: String)
}

final class SetPasswordViewController: UIViewController {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var verifiableInput: VerifiableInput!
    private weak var delegate: SetPasswordViewControllerDelegate?

    enum Strings {
        static let title = LocalizedString("onboarding.set_password.title",
                                           comment: "Set password screen title.")
        static let header = LocalizedString("onboarding.set_password.header",
                                            comment: "Set password screen header.")
        static let description = LocalizedString("onboarding.set_password.description",
                                                 comment: "Set password screen description.")
        static let length = LocalizedString("onboarding.set_password.length",
                                            comment: "Use a minimum of 8 characters.")
        static let capitalAndDigit = LocalizedString("onboarding.set_password.capital_and_number",
                                                     comment: "At least 1 number and 1 letter.")
        static let trippleChars = LocalizedString("onboarding.set_password.no_tripple_chars",
                                                  comment: "No triple characters.")
    }

    static func create(delegate: SetPasswordViewControllerDelegate?) -> SetPasswordViewController {
        let vc = StoryboardScene.MasterPassword.setPasswordViewController.instantiate()
        vc.delegate = delegate
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Strings.title
        headerLabel.text = Strings.header
        verifiableInput.delegate = self
        verifiableInput.isSecure = true
        verifiableInput.addRule(Strings.length) { PasswordValidator.validateMinLength($0) }
        verifiableInput.addRule(Strings.capitalAndDigit) {
            PasswordValidator.validateAtLeastOneCapitalLetterAndOneDigit($0)
        }
        verifiableInput.addRule(Strings.trippleChars) { PasswordValidator.validateNoTrippleChar($0) }
        _ = verifiableInput.becomeFirstResponder()
    }

}

extension SetPasswordViewController: VerifiableInputDelegate {

    func verifiableInputDidReturn(_ verifiableInput: VerifiableInput) {
        delegate?.didSetPassword(verifiableInput.text!)
    }

}
