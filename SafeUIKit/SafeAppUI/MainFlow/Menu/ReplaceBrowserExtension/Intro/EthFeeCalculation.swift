//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit
import SafeUIKit

class EthFeeCalculation: FeeCalculation {

    enum Strings {

        static let currentBalance = LocalizedString("safe_balance", comment: "Current balance")
        static let networkFee = LocalizedString("transaction_fee", comment: "Network fee")
        static let balance = LocalizedString("balance_after_transfer", comment: "Balance after transfer")
        static let loadingEth = "- ETH"
        static let feeInfo = "[?]"

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

    override func update() {
        var section = FeeCalculationSection([currentBalance, networkFee, emptyLine, balance])
        if let error = error {
            section.append(error)
        }
        set(contents: [section])
    }

}