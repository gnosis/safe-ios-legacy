//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

extension SuccessViewController {

    static func createSendSuccess(action: @escaping () -> Void) -> SuccessViewController {
        return .create(title: LocalizedString("congratulations", comment: "Congratulations!"),
                       detail: LocalizedString("transaction_has_been_submitted", comment: "Explanation text"),
                       image: Asset.congratulations.image,
                       actionTitle: LocalizedString("continue_text", comment: "Continue"),
                       action: action)

    }

}
