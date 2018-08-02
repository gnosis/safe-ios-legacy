//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

fileprivate struct LocalizationStrings {

    static let pushSignatureRequestTitle =
        NSLocalizedString("push.signature_request",
                          comment: "Title for request from browser extension to sign a transaction.")
    static let pushSignatureResponsePositiveTitle =
        NSLocalizedString("push.signature_response.positive",
                          comment: "Title for positive response from browser extension with signature.")
    static let pushSignatureResponseNegativeTitle =
        NSLocalizedString("push.signature_response.negative",
                          comment: "Title for negative response from browser extension without signature.")

}
