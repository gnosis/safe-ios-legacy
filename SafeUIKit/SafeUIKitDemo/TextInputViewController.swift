//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class TextInputViewController: UIViewController {

    @IBOutlet weak var simpleTextInput: TextInput!

    override func viewDidLoad() {
        super.viewDidLoad()
        simpleTextInput.placeholder = "Simple Text Input"
        simpleTextInput.isDimmed = true
    }

    @IBAction func setIconForSimpleTextInput(_ sender: Any) {
        simpleTextInput.leftImage = UIImage(named: "ETH")
        simpleTextInput.resignFirstResponder()
    }

    @IBAction func removeIconForSimpleTextInput(_ sender: Any) {
        simpleTextInput.leftImage = nil
        simpleTextInput.resignFirstResponder()
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
