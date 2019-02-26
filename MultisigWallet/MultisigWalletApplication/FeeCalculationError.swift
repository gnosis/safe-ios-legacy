//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public class FeeCalculationError: NSError {

    public static let domain = "io.gnosis.safe.settings"

    enum Description {
        static let insufficientBalance = LocalizedString("fee_calculation.error.insufficient_balance",
                                                         comment: "Insufficient funds.\nPlease add ETH to your Safe.")
        static let extensionNotFound = LocalizedString("fee_calculation.error.extension_not_found",
                                                       comment: "Browser extension is not connected.")
        static let extensionExists = LocalizedString("fee_calculation.error.extension_exists",
                                                     comment: "Browser extension is not connected.")

    }
    public enum Code: Int {
        case insufficientBalance
        case extensionNotFound
        case extensionExists
    }

    public static let insufficientBalance =
        FeeCalculationError(domain: FeeCalculationError.domain,
                            code: Code.insufficientBalance.rawValue,
                            userInfo: [NSLocalizedDescriptionKey: Description.insufficientBalance])

    public static let extensionNotFound =
        FeeCalculationError(domain: FeeCalculationError.domain,
                            code: Code.extensionNotFound.rawValue,
                            userInfo: [NSLocalizedDescriptionKey: Description.extensionNotFound])

    public static let extensionExists =
        FeeCalculationError(domain: FeeCalculationError.domain,
                            code: Code.extensionNotFound.rawValue,
                            userInfo: [NSLocalizedDescriptionKey: Description.extensionExists])

}
