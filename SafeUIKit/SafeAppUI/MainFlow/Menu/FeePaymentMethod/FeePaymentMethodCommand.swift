//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

final class FeePaymentMethodCommand: MenuCommand {

    override var title: String {
        return LocalizedString("fee_payment_method", comment: "Fee Payment Method").capitalized
    }

    override func run(mainFlowCoordinator: MainFlowCoordinator) {
        mainFlowCoordinator.push(PaymentMethodViewController())
    }

}
