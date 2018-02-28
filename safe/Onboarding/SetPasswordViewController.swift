//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit
import safeUIKit

final class SetPasswordViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var textInput: TextInput!

    static func create() -> SetPasswordViewController {
        return StoryboardScene.Onboarding.setPasswordViewController.instantiate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        textInput.addRule("Minimun 6 charachters") { PasswordValidator.validateMinLength($0) }
        textInput.addRule("Should have a capital letter") { PasswordValidator.validateAtLeastOneCapitalLetter($0) }
        textInput.addRule("Should have a digit") { PasswordValidator.validateAtLeastOneDigit($0) }
        _ = textInput.becomeFirstResponder()
    }

}
