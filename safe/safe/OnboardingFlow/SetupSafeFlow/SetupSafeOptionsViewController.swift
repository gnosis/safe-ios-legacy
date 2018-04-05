//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit
import safeUIKit

class SetupSafeOptionsViewController: UIViewController {

    @IBOutlet weak var headerLabel: H1Label!
    @IBOutlet weak var newSafeButton: BigButton!
    @IBOutlet weak var restoreSafeButton: BigButton!

    static func create() -> SetupSafeOptionsViewController {
        return StoryboardScene.SetupSafe.setupSafeOptionsViewController.instantiate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
