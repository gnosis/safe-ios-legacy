//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

// swiftlint:disable line_length
class TokenInputViewController: UIViewController {

    @IBOutlet weak var tokenInput: TokenInput!

    override func viewDidLoad() {
        super.viewDidLoad()
        tokenInput.imageURL = URL(string: "https://github.com/TrustWallet/tokens/blob/master/images/0x6810e776880c02933d47db1b9fc05908e5386b96.png?raw=true")
    }

    @IBAction func set18deciamlDigits(_ sender: Any) {
        tokenInput.setUp(value: 0, decimals: 18)
    }

    @IBAction func set5deciamlDdigits(_ sender: Any) {
        tokenInput.setUp(value: 0, decimals: 5)
    }

    @IBAction func set0deciamlDdigits(_ sender: Any) {
        tokenInput.setUp(value: 0, decimals: 0)
    }

    @IBAction func resign(_ sender: Any) {
        _ = tokenInput.resignFirstResponder()
    }

}
