//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

class BaseDemoViewController: UIViewController {

    var wasPresented = false
    var demoController: UIViewController { preconditionFailure("Not implemented") }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !wasPresented else { return }
        wasPresented = true
        DispatchQueue.main.async {
            self.present(self.demoController, animated: true, completion: nil)
        }
    }

}
