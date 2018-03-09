//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit
import safeUIKit

protocol UnlockViewControllerDelegate: class {
    func didLogIn()
}

final class UnlockViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var textInput: TextInput!
    @IBOutlet weak var loginWithBiometryButton: UIButton!
    private weak var delegate: UnlockViewControllerDelegate?
    private var account: AccountProtocol!

    static func create(account: AccountProtocol, delegate: UnlockViewControllerDelegate?) -> UnlockViewController {
        let vc = StoryboardScene.AppFlow.unlockViewController.instantiate()
        vc.account = account
        vc.delegate = delegate
        return vc
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        account.authenticateWithBiometry { [unowned self] success in
            self.delegate?.didLogIn()
        }
    }

}
