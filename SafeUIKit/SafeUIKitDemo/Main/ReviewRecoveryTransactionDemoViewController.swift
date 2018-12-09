//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeAppUI
import Common
import BigInt

class ReviewRecoveryTransactionDemoViewController: BaseDemoViewController {

    var controller: ReviewRecoveryTransactionViewController!
    var navController: UINavigationController!
    override var demoController: UIViewController { return navController }

    override func viewDidLoad() {
        super.viewDidLoad()
        controller = .create()
        navController = UINavigationController(rootViewController: controller)
        navController.navigationBar.barTintColor = .white
        navController.navigationBar.isTranslucent = false
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.shadowImage = UIImage()

        controller.safeAddress = "0x1CBFf6551B8713296b0604705B1a3B76D238Ae14"
        controller.feeBalance = TokenData.Ether.withBalance(BigInt(10e18) + BigInt(22e13))
        controller.feeAmount = TokenData.Ether.withBalance(-BigInt(12e13))
        controller.resultingBalance = TokenData.Ether.withBalance(BigInt(10e18) + BigInt(1e14))
    }

}
