//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

final class MainFlowCoordinator: FlowCoordinator {

    private var walletService: WalletApplicationService {
        return MultisigWalletApplication.ApplicationServiceRegistry.walletService
    }

    override func setUp() {
        super.setUp()
        let mainVC = MainViewController.create(delegate: self)
        push(mainVC)
    }

}

extension MainFlowCoordinator: MainViewControllerDelegate {

    func mainViewDidAppear() {
        UIApplication.shared.requestRemoteNotificationsRegistration()
        // TODO: implement
        let fcmToken = "token"
        try! walletService.authWithPushToken(fcmToken)
    }

}
