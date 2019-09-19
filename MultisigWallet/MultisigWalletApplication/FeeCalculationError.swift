//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public class FeeCalculationError: NSError {

    public static let domain = "io.gnosis.safe.settings"

    enum Strings {
        static let insufficientBalance = LocalizedString("exceeds_funds",
                                                         comment: "Insufficient funds to perform this transaction.")
        static let twoFANotFound = LocalizedString("two_fa_not_connected", comment: "2FA is not connected.")
        static let twoFAAlreadyExists = LocalizedString("two_fa_already_connected",
                                                        comment: "2FA is already connected.")
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

    public static let TwoFANotFound =
        FeeCalculationError(domain: FeeCalculationError.domain,
                            code: Code.extensionNotFound.rawValue,
                            userInfo: [NSLocalizedDescriptionKey: Strings.twoFANotFound])

    public static let twoFAAlreadyExists =
        FeeCalculationError(domain: FeeCalculationError.domain,
                            code: Code.extensionNotFound.rawValue,
                            userInfo: [NSLocalizedDescriptionKey: Strings.twoFAAlreadyExists])

}
