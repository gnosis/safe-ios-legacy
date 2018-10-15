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
        simpleTextInput.leftImage = UIImage(named: "default-token")
        simpleTextInput.leftImageURL = URL(string: "https://raw.githubusercontent.com/rmeissner/crypto_resources/master/tokens/rinkeby/icons/0x979861dF79C7408553aAF20c01Cfb3f81CCf9341.png")
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
