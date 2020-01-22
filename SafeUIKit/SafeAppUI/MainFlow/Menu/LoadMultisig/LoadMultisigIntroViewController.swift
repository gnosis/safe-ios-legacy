//
//  Copyright © 2020 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class LoadMultisigIntroViewController: UIViewController {

    @IBOutlet weak var loadMultisigButton: StandardButton!

    @IBAction func loadMultisig(_ sender: Any) {
        print("load")
    }

    static func create() -> LoadMultisigIntroViewController {
        return LoadMultisigIntroViewController(nibName: "LoadMultisigIntroViewController",
                                               bundle: Bundle(for: LoadMultisigIntroViewController.self))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadMultisigButton.style = .filled
    }

}
