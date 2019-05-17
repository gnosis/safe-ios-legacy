//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public class FeeCalculationError: NSError {

    public static let domain = "io.gnosis.safe.settings"

    enum Strings {
        static let insufficientBalance = LocalizedString("exceeds_funds",
                                                         comment: "Insufficient funds to perform this transaction.")
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
                            userInfo: [NSLocalizedDescriptionKey: Strings.insufficientBalance])

    public static let extensionNotFound =
        FeeCalculationError(domain: FeeCalculationError.domain,
                            code: Code.extensionNotFound.rawValue,
                            userInfo: [NSLocalizedDescriptionKey: Strings.extensionNotFound])

    public static let extensionExists =
        FeeCalculationError(domain: FeeCalculationError.domain,
                            code: Code.extensionNotFound.rawValue,
                            userInfo: [NSLocalizedDescriptionKey: Strings.extensionExists])

}
