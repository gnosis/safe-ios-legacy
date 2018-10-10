//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class VerifiableInputViewController: UIViewController {

    @IBOutlet weak var verifiableInput: VerifiableInput!

    @IBAction func addSuccessRule(_ sender: Any) {
        verifiableInput.addRule("Success Rule") { _ in true }
    }

    @IBAction func addFailingRule(_ sender: Any) {
        verifiableInput.addRule("Failing Rule") { _ in false }
    }

    @IBAction func addEmptyRule(_ sender: Any) {
        verifiableInput.addRule("Empty Rule")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        verifiableInput.accessibilityIdentifier = "testVerifiableInput"
        verifiableInput.isDimmed = true
    }

}
