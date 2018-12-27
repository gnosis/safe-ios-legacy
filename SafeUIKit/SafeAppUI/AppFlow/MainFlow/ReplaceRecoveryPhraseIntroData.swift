//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public struct ReplaceRecoveryPhraseIntroData {

    var currentBalanceData: TokenData
    var transactionFeeData: TokenData
    var resultingBalanceData: TokenData
    var hasInsufficientFunds: Bool
    var canStart: Bool
    var canRetry: Bool
    var canCanel: Bool

    // sourcery:inline:ReplaceRecoveryPhraseIntroData.StructInit
    // swiftlint:disable vertical_parameter_alignment
    public init(currentBalanceData: TokenData,
        transactionFeeData: TokenData,
        resultingBalanceData: TokenData,
        hasInsufficientFunds: Bool,
        canStart: Bool,
        canRetry: Bool,
        canCanel: Bool) {
        self.currentBalanceData = currentBalanceData
        self.transactionFeeData = transactionFeeData
        self.resultingBalanceData = resultingBalanceData
        self.hasInsufficientFunds = hasInsufficientFunds
        self.canStart = canStart
        self.canRetry = canRetry
        self.canCanel = canCanel
    }
    // swiftlint:enable vertical_parameter_alignment
    // sourcery:end

}
