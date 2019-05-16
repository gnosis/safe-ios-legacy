//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

extension SuccessViewController {

    static func createSendSuccess(token: TokenData, action: @escaping () -> Void) -> SuccessViewController {
        return .create(title: LocalizedString("congratulations", comment: "Congratulations!"),
                       detail: LocalizedString("transaction_has_been_submitted", comment: "Explanation text"),
                       image: Asset.congratulations.image,
                       screenTrackingEvent: SendTrackingEvent(.success, token: token.address, tokenName: token.code),
                       actionTitle: LocalizedString("continue_text", comment: "Continue"),
                       action: action)
    }

}
