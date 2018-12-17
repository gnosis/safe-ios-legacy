//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class AddressInputViewController: UIViewController {

    @IBOutlet weak var addressInput: AddressInput!
    @IBOutlet weak var inputValueLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        addressInput.addressInputDelegate = self
        inputValueLabel.text = addressInput.text
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
    
}
