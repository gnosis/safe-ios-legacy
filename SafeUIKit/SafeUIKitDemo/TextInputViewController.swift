//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

// swiftlint:disable line_length
class TextInputViewController: UIViewController {

    @IBOutlet weak var simpleTextInput: TextInput!

    override func viewDidLoad() {
        super.viewDidLoad()
        simpleTextInput.placeholder = "Simple Text Input"
        simpleTextInput.isDimmed = true
    }

    @IBAction func setIconForSimpleTextInput(_ sender: Any) {
        simpleTextInput.leftImage = UIImage(named: "gnosis-icon")
        simpleTextInput.resignFirstResponder()
    }

    @IBAction func removeIconForSimpleTextInput(_ sender: Any) {
        simpleTextInput.leftImage = nil
        simpleTextInput.leftImageURL = nil
        simpleTextInput.resignFirstResponder()
    }

    @IBAction func setIconFromURL(_ sender: Any) {
        simpleTextInput.leftImage = nil
        simpleTextInput.leftImageURL = URL(string: "https://github.com/TrustWallet/tokens/blob/master/images/0x6810e776880c02933d47db1b9fc05908e5386b96.png?raw=true")
    }

    @IBAction func setDimmed(_ sender: Any) {
        simpleTextInput.isDimmed = true
        simpleTextInput.resignFirstResponder()
    }

    @IBAction func setNotDimmed(_ sender: Any) {
        simpleTextInput.isDimmed = false
        simpleTextInput.resignFirstResponder()
    }

    @IBAction func resignFirstResponder(_ sender: Any) {
        simpleTextInput.resignFirstResponder()
    }

}
