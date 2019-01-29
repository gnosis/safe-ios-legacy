//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit
import SafeAppUI

class EmptyDemoController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        push()
    }

    @IBAction func push() {
        let controller = RBEIntroViewController.create()
        navigationController?.pushViewController(controller, animated: true)
    }

}
