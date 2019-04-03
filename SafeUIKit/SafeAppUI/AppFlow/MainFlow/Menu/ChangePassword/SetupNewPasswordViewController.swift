//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

protocol SetupNewPasswordViewControllerDelegate: class {
    func didEnterNewPassword(_ password: String)
}

final class SetupNewPasswordViewController: UIViewController {

    private weak var delegate: SetupNewPasswordViewControllerDelegate!

    static func create(delegate: SetupNewPasswordViewControllerDelegate) -> SetupNewPasswordViewController {
        let vc = StoryboardScene.ChangePassword.setupNewPasswordViewController.instantiate()
        vc.delegate = delegate
        return vc
    }

    enum Strings {
        static let title = LocalizedString("change_password.title", comment: "Title for change password screen")
        static let save = LocalizedString("save", comment: "Save button")
        static let header = LocalizedString("new_password.header", comment: "Header for new password screen")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
