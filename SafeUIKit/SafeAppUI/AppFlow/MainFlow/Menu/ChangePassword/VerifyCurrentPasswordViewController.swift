//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

protocol VerifyCurrentPasswordViewControllerDelegate: class {}

final class VerifyCurrentPasswordViewController: UIViewController {

    weak var delegate: VerifyCurrentPasswordViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
