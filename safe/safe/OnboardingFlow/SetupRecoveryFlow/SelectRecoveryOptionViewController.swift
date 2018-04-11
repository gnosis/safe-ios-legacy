//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

protocol SetupRecoveryOptionDelegate: class {}

class SelectRecoveryOptionViewController: UIViewController {

    weak var delegate: SetupRecoveryOptionDelegate?

    static func create(delegate: SetupRecoveryOptionDelegate) -> SelectRecoveryOptionViewController {
        return StoryboardScene.SetupRecovery.selectRecoveryOptionViewController.instantiate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
