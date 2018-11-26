//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

final class IdenticonViewController: UIViewController {

    @IBOutlet weak var identiconView: IdenticonView!

    override func viewDidLoad() {
        super.viewDidLoad()
        identiconView.displayShadow = false
        identiconView.seed = "Test it!"
    }

    @IBAction func addShadow(_ sender: Any) {
        identiconView.displayShadow = true
        identiconView.seed = "Test it!"
    }

    @IBAction func removeShadow(_ sender: Any) {
        identiconView.displayShadow = false
        identiconView.seed = "New Seed"
    }
    
}
