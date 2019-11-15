//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class AddressInputViewController: UIViewController {

    @IBOutlet weak var addressInput: AddressInput!
    @IBOutlet weak var tokenInput: TokenInput!
    @IBOutlet weak var inputValueLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        addressInput.addressInputDelegate = self
        inputValueLabel.text = addressInput.text
        tokenInput.imageURL = URL(string: "https://raw.githubusercontent.com/rmeissner/crypto_resources/master/tokens/rinkeby/icons/0x979861dF79C7408553aAF20c01Cfb3f81CCf9341.png")
        tokenInput.tokenCode = "GNO"
    }

    @IBAction func showValue(_ sender: Any) {
        inputValueLabel.text = addressInput.text
    }

}

extension AddressInputViewController: AddressInputDelegate {

    func didRecieveInvalidAddress(_ string: String) {}

    func didClear() {}

    func didRecieveValidAddress(_ address: String) {}

    func presentController(_ controller: UIViewController) {
        present(controller, animated: true)
    }

    func nameForAddress(_ address: String) -> String? {
        return "Test Account"
    }

    func didRequestAddressBook() {}
    func didRequestENSName() {}
    
}
