//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit

class EthFeeCalculation: FeeCalculation {

    enum Strings {

        static let currentBalance = LocalizedString("fee_calculation.current_balance", comment: "Current balance")
        static let networkFee = LocalizedString("fee_calculation.fee", comment: "Network fee")
        static let balance = LocalizedString("fee_calculation.balance", comment: "Balance")
        static let loadingEth = LocalizedString("fee_calculation.value.loading_eth", comment: "- ETH")
        static let feeInfo = LocalizedString("fee_calculation.fee.info", comment: "[?]")

    }

    var currentBalance: FeeCalculationAssetLine
    var networkFee: FeeCalculationAssetLine
    var balance: FeeCalculationAssetLine
    var emptyLine = FeeCalculationSpacingLine(spacing: 12)
    var error: FeeCalculationErrorLine?

    required init() {
        currentBalance = FeeCalculationAssetLine().set(style: .balance).set(name: Strings.currentBalance)
            .set(value: Strings.loadingEth)
        networkFee = FeeCalculationAssetLine().set(name: Strings.networkFee).set(value: Strings.loadingEth)
            .set(button: Strings.feeInfo, action: #selector(RBEIntroViewController.showNetworkFeeInfo))
        balance = FeeCalculationAssetLine().set(style: .balance).set(name: Strings.balance)
            .set(value: Strings.loadingEth)
        super.init()
        update()
    }

    func update() {
        var section = FeeCalculationSection([currentBalance, networkFee, emptyLine, balance])
        if let error = error {
            section.append(error)
        }
        elements = [section]
    }

}
