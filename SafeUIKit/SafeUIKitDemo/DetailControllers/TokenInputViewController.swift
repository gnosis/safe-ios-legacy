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
        tokenInput.imageURL = URL(string: "https://raw.githubusercontent.com/rmeissner/crypto_resources/master/tokens/rinkeby/icons/0x979861dF79C7408553aAF20c01Cfb3f81CCf9341.png")
        tokenInput.tokenCode = "GNO"
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
