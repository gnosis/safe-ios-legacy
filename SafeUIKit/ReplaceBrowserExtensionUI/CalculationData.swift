//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

struct EthNumber {
    var data: Data
}

struct EthAddress {
    var value: EthNumber
}

struct TokenData {
    var amount: EthNumber
    var token: String
}

extension TokenData: ExpressibleByStringLiteral {

    init(stringLiteral value: String) {
        amount = EthNumber(data: Data())
        token = "ETH"
    }

}

struct CalculationData {
    var currentBalance: TokenData
    var networkFee: TokenData
    var balance: TokenData
}

public class FeeCalculationError: NSError {

    public static let domain = "io.gnosis.safe.rbe"

    enum Description {
        static let insufficientBalance = LocalizedString("fee_calculation.error.insufficient_balance",
                                                         comment: "Insufficient funds error text")
    }
    public enum Code: Int {
        case insufficientBalance
    }

    public static let insufficientBalance =
        FeeCalculationError(domain: FeeCalculationError.domain,
                            code: Code.insufficientBalance.rawValue,
                            userInfo: [NSLocalizedDescriptionKey: Description.insufficientBalance])
}
