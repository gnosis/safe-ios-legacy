//
//  Copyright © 2020 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

protocol LoadMultisigIntroViewControllerDelegate: class {
    func loadMultisigIntroViewControllerDidSelectLoad(_ controller: LoadMultisigIntroViewController)
}

class LoadMultisigIntroViewController: UIViewController {

    @IBOutlet weak var loadMultisigButton: StandardButton!
    weak var delegate: LoadMultisigIntroViewControllerDelegate?

    @IBAction func loadMultisig(_ sender: Any) {
        delegate?.loadMultisigIntroViewControllerDidSelectLoad(self)
    }

    static func create(delegate: LoadMultisigIntroViewControllerDelegate) -> LoadMultisigIntroViewController {
        let controller = LoadMultisigIntroViewController(nibName: "LoadMultisigIntroViewController",
                                                         bundle: Bundle(for: LoadMultisigIntroViewController.self))
        controller.delegate = delegate
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadMultisigButton.style = .filled
    }

}
