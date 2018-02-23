//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

final class SetPasswordViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!

    static func create() -> SetPasswordViewController {
        return StoryboardScene.Onboarding.setPasswordViewController.instantiate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
