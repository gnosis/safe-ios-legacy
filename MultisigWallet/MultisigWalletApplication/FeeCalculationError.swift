//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public class FeeCalculationError: NSError {

    public static let domain = "io.gnosis.safe.settings"

    enum Description {
        static let insufficientBalance = LocalizedString("exceeds_funds",
                                                         comment: "Insufficient funds.\nPlease add %@ to your Safe.")
        static let extensionNotFound = LocalizedString("ios_error_extension_notfound",
                                                       comment: "Browser extension is not connected.")
        static let extensionExists = LocalizedString("ios_error_extension_exists",
                                                     comment: "Browser extension is already connected.")
    }

    public enum Code: Int {
        case insufficientBalance
        case extensionNotFound
        case extensionExists
    }

    public static let insufficientBalance =
        FeeCalculationError(domain: FeeCalculationError.domain,
                            code: Code.insufficientBalance.rawValue,
                            userInfo: [NSLocalizedDescriptionKey:
                                String(format: Description.insufficientBalance, "ETH")])

    public static let extensionNotFound =
        FeeCalculationError(domain: FeeCalculationError.domain,
                            code: Code.extensionNotFound.rawValue,
                            userInfo: [NSLocalizedDescriptionKey: Description.extensionNotFound])

    public static let extensionExists =
        FeeCalculationError(domain: FeeCalculationError.domain,
                            code: Code.extensionNotFound.rawValue,
                            userInfo: [NSLocalizedDescriptionKey: Description.extensionExists])

}
