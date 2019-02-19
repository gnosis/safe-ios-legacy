//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit
import SafeAppUI
import MultisigWalletApplication
import Common

class ConnectExtensionDemoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        ApplicationServiceRegistry.put(service: MockLogger(), for: Logger.self)
        ApplicationServiceRegistry.put(service: MockWalletApplicationService(), for: WalletApplicationService.self)
        ApplicationServiceRegistry.put(service: MockEthereumApplicationService(), for: EthereumApplicationService.self)
        push()
    }
    
    @IBAction func push() {
        let controller = PairWithBrowserExtensionViewController.createRBEConnectController(delegate: self)
        navigationController?.pushViewController(controller, animated: true)

        Timer.scheduledTimer(withTimeInterval: 1.25, repeats: false) { _ in
            controller.showLoadingTitle()
        }
    }

}


extension ConnectExtensionDemoViewController: PairWithBrowserExtensionViewControllerDelegate {

    func pairWithBrowserExtensionViewController(_ controller: PairWithBrowserExtensionViewController,
                                                didPairWith address: String,
                                                code: String) {

    }

    func pairWithBrowserExtensionViewControllerDidSkipPairing() {

    }



}
