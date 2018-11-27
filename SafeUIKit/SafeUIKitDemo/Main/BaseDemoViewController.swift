//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

class BaseDemoViewController: UIViewController {

    var demoController: UIViewController { preconditionFailure("Not implemented") }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        DispatchQueue.main.async {
            self.present(self.demoController, animated: true, completion: nil)
        }
    }

}
