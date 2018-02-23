//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

final class SetPasswordViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var minimumLengthRuleLabel: RuleLabel!
    @IBOutlet weak var capitalLetterRuleLabel: RuleLabel!
    @IBOutlet weak var digitRuleLabel: RuleLabel!

    static func create() -> SetPasswordViewController {
        return StoryboardScene.Onboarding.setPasswordViewController.instantiate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.becomeFirstResponder()
    }

    func setMinimumLengthRuleStatus(_ status: RuleStatus) {
        minimumLengthRuleLabel.status = status
    }

    func setCapitalLetterRuleStatus(_ status: RuleStatus) {
        capitalLetterRuleLabel.status = status
    }

    func setDigitRuleStatus(_ status: RuleStatus) {
        digitRuleLabel.status = status
    }

}
