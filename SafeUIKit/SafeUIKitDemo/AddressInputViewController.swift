//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class AddressInputViewController: UIViewController {

    @IBOutlet weak var addressInput: AddressInput!

    override func viewDidLoad() {
        super.viewDidLoad()
        addressInput.addressInputDelegate = self
    }

}

extension AddressInputViewController: AddressInputDelegate {

    func presentController(_ controller: UIViewController) {
        present(controller, animated: true)
    }
    
}
