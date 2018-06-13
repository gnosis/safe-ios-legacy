//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import BigInt

class TokenInputViewController: UIViewController {

    @IBOutlet var tokenInput: TokenInput!

    override func viewDidLoad() {
        super.viewDidLoad()
        tokenInput.setUp(value: 0, decimals: 5, fiatConvertionRate: 0.1, locale: Locale.current)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func hideKeyboard() {        
        _ = tokenInput.resignFirstResponder()
    }

}
