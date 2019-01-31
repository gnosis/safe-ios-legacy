//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit

extension FeeCalculation {

    enum Strings {

        static let currentBalance = LocalizedString("fee_calculation.current_balance", comment: "Current balance")
        static let networkFee = LocalizedString("fee_calculation.fee", comment: "Network fee")
        static let balance = LocalizedString("fee_calculation.balance", comment: "Balance")
        static let loadingEth = LocalizedString("fee_calculation.value.loading_eth", comment: "- ETH")
        static let feeInfo = LocalizedString("fee_calculation.fee.info", comment: "[?]")
    }

    static let loading = FeeCalculation().addSection {
        $0.addAssetLine { $0.set(style: .balance).set(name: Strings.currentBalance).set(value: Strings.loadingEth) }
        .addAssetLine { $0.set(name: Strings.networkFee).set(value: Strings.loadingEth).set(button: Strings.feeInfo) }
        .addEmptyLine()
        .addAssetLine { $0.set(style: .balance).set(name: Strings.balance).set(value: Strings.loadingEth) }
    }

}
