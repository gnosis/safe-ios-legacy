//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeAppUI
import Common
import BigInt
import MultisigWalletApplication

class FundTransferDemoViewController: BaseDemoViewController {

    var controller: FundsTransferTransactionViewController!
    var navController: UINavigationController!
    override var demoController: UIViewController { return navController }

    let service = MockWalletApplicationService()

    override func viewDidLoad() {
        super.viewDidLoad()
        ApplicationServiceRegistry.put(service: service, for: WalletApplicationService.self)
        service.createReadyToUseWallet()
        service.update(account: ethID, newBalance: BigInt(1e18) + BigInt(3e14))
        service.update(account: ethID, newBalance: BigInt(1e18))
        service.estimatedFee_output = BigInt(1e14)
        controller = .create(tokenID: ethID)
        navController = UINavigationController(rootViewController: controller)
    }

}
