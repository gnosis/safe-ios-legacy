//
//  Copyright © 2020 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

protocol LoadMultisigIntroViewControllerDelegate: class {
    func loadMultisigIntroViewControllerDidSelectLoad(_ controller: LoadMultisigIntroViewController)
}

class LoadMultisigIntroViewController: UIViewController {

    enum Strings {
        static let description = """
You can load a Gnosis Safe Multisig where your personal Gnosis Safe is an owner.
After a Multisig is loaded you can initiate, confirm, execute Multisig Safe transactions with your Personal Safe.
"""
        static let reference = """
To create and manage a Multisig Safe you can use our web-interface at https://gnosis-safe.io
"""
    }

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var referenceLabel: UILabel!

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
        title = "Load Multisig"
        loadMultisigButton.style = .filled
        descriptionLabel.attributedText = NSAttributedString(string: Strings.description, style: DescriptionStyle())
        referenceLabel.attributedText = NSAttributedString(string: Strings.reference, style: DescriptionStyle())
    }

}
