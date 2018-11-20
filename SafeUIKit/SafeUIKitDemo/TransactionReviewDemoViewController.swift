//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import SafeAppUI
import MultisigWalletApplication
import Common

class TransactionReviewDemoViewController: UIViewController {

    var controller: TransactionReviewViewController!
    var walletService = MockWalletApplicationService()

    override func viewDidLoad() {
        super.viewDidLoad()
        ApplicationServiceRegistry.put(service: walletService, for: WalletApplicationService.self)
        walletService.transactionData_output = .default
        walletService.requestTransactionConfirmation_output = .default
        walletService.update(account: ethID, newBalance: 90000000000000000)
        controller = .create()
        controller.transactionID = "TxID"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.present(self.controller, animated: true, completion: nil)
        }
    }

}

extension TransactionData {

    static let `default` = TransactionData(id: "TxID",
                                           sender: "0x2333b4cc1f89a0b4c43e9e733123c124aae977ee",
                                           recipient: "0x7eb15f032bb60605a5302f1bc2c3c38a80888f27",
                                           amount: 2000000000000,
                                           token: "ETH",
                                           tokenDecimals: 18,
                                           tokenLogoUrl: "",
                                           fee: 30000000,
                                           feeToken: "ETH",
                                           feeTokenDecimals: 18,
                                           status: .readyToSubmit,
                                           type: .outgoing,
                                           created: Date(timeIntervalSinceNow: -3 * 60 * 60),
                                           updated: Date(timeIntervalSinceNow: -2 * 60 * 60),
                                           submitted: nil,
                                           rejected: nil,
                                           processed: nil)

}
