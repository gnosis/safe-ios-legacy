//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import SafeAppUI
import MultisigWalletApplication
import Common

class TransactionReviewDemoViewController: BaseDemoViewController {

    override var demoController: UIViewController { return controller }
    var controller: TransactionReviewViewController!
    var walletService = MockWalletApplicationService()

    override func viewDidLoad() {
        super.viewDidLoad()
        ApplicationServiceRegistry.put(service: walletService, for: WalletApplicationService.self)
        walletService.transactionData_output = .default
        walletService.requestTransactionConfirmation_output = .default
        walletService.update(account: ethID, newBalance: 90_000_000_000_000_000)
        controller = .create()
        controller.transactionID = "TxID"
    }

}

extension TransactionData {

    static let `default` = TransactionData(id: "TxID",
                                           sender: "0x2333b4cc1f89a0b4c43e9e733123c124aae977ee",
                                           recipient: "0x7eb15f032bb60605a5302f1bc2c3c38a80888f27",
                                           amountTokenData: TokenData.Ether.withBalance(2_000_000_000_000),
                                           feeTokenData: TokenData.Ether.withBalance(30_000_000),
                                           status: .readyToSubmit,
                                           type: .outgoing,
                                           created: Date(timeIntervalSinceNow: -3 * 60 * 60),
                                           updated: Date(timeIntervalSinceNow: -2 * 60 * 60),
                                           submitted: nil,
                                           rejected: nil,
                                           processed: nil)

}
