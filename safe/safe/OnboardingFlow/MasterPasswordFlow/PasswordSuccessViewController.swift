//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

final class PasswordSuccessViewController: UIViewController {

    @IBOutlet weak var successLabel: UILabel!

    static func create() -> PasswordSuccessViewController {
        return StoryboardScene.MasterPassword.passwordSuccessViewController.instantiate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        successLabel.text = NSLocalizedString("onboarding.passsword_success.status", comment: "Password success label")
    }

}
