//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit
import safeUIKit

class ConfirmPaswordViewController: UIViewController {

    @IBOutlet weak var textInput: TextInput!
    private var referencePassword: String!

    static func create(referencePassword: String) -> ConfirmPaswordViewController {
        let vc = StoryboardScene.MasterPassword.confirmPaswordViewController.instantiate()
        vc.referencePassword = referencePassword
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: 01/03/18: Localize rule
        textInput.addRule("• Passwords must match") { [unowned self] input in
            PasswordValidator.validate(input: input, equals: self.referencePassword)
        }
        _ = textInput.becomeFirstResponder()
    }

}
