//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

protocol ConfirmMnemonicDelegate: class {
    func didConfirm()
}

final class ConfirmMnemonicViewController: UIViewController {

    weak var delegate: ConfirmMnemonicDelegate?

    static func create(delegate: ConfirmMnemonicDelegate) -> ConfirmMnemonicViewController {
        let controller = ConfirmMnemonicViewController()
        controller.delegate = delegate
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
