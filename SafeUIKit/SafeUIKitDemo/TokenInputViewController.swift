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

}
