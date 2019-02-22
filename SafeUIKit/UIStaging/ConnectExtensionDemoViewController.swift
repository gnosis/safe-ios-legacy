//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit
import SafeAppUI
import MultisigWalletApplication
import MultisigWalletDomainModel
import BigInt
import Common

class ConnectExtensionDemoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ethereumService = MockEthereumApplicationService()
        ethereumService.browserExtensionAddress = "SomeValidAddressToMakeScanningGoThrough"

        let mockWalletService = MockWalletApplicationService()
        mockWalletService.transactionData_output =
            TransactionData(id: "tx",
                            sender: "",
                            recipient: "",
                            amountTokenData: TokenData.Ether,
                            feeTokenData: TokenData.Ether,
                            status: .readyToSubmit,
                            type: .replaceBrowserExtension,
                            created: Date(),
                            updated: nil,
                            submitted: nil,
                            rejected: nil,
                            processed: nil)
        mockWalletService.update(account: Token.Ether.id, newBalance: BigInt(10e17))

        ApplicationServiceRegistry.put(service: MockLogger(), for: Logger.self)
        ApplicationServiceRegistry.put(service: mockWalletService, for: WalletApplicationService.self)
        ApplicationServiceRegistry.put(service: ethereumService, for: EthereumApplicationService.self)

        push()
    }
    
    @IBAction func push() {
        let controller = ReplaceBrowserExtensionReviewTransactionViewController(transactionID: "tx", delegate: self)
        navigationController?.pushViewController(controller, animated: true)
    }

}


extension ConnectExtensionDemoViewController: ReviewTransactionViewControllerDelegate {

    func wantsToSubmitTransaction(_ completion: @escaping (Bool) -> Void) {}

    func didFinishReview() {}

}
