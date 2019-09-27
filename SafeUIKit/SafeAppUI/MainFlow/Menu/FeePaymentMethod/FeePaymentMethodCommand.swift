//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

final class FeePaymentMethodCommand: MenuCommand {

    override var title: String {
        return LocalizedString("fee_payment_method", comment: "Fee Payment Method").capitalized
    }

    override var isHidden: Bool {
        return !ApplicationServiceRegistry.walletService.hasReadyToUseWallet
    }

    override func run() {
        MainFlowCoordinator.shared.push(PaymentMethodViewController())
    }

}
