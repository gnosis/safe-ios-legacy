//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

protocol CBEIntroViewControllerDelegate: class {
    func introViewControllerDidStart()
}

class CBEIntroViewController: UIViewController {

    weak var delegate: CBEIntroViewControllerDelegate?
    var transactionID: CBETransactionID?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
