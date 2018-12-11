//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeAppUI

class DemoRecoveryInProgressViewControllerViewController: BaseDemoViewController {

    var controller: RecoveryInProgressViewController!
    var navController: UINavigationController!
    override var demoController: UIViewController { return navController }

    override func viewDidLoad() {
        super.viewDidLoad()
        controller = .create(delegate: nil)
        navController = UINavigationController(rootViewController: UIViewController())
        navController.navigationBar.barTintColor = .white
        navController.navigationBar.isTranslucent = false
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.shadowImage = UIImage()
        navController.pushViewController(controller, animated: false)
    }

}
