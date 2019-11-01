//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

final class TooltipControlCenter {

    static func showFirstTimeTooltip(persistenceKey: String, target: UIView, parent: UIView, text: String) {
        if true || !UserDefaults.standard.bool(forKey: persistenceKey) {
            UserDefaults.standard.set(true, forKey: persistenceKey)
            DispatchQueue.main.async {
                FeedbackTooltip.show(for: target,
                                     in: parent,
                                     message: text,
                                     greenStyle: true,
                                     aboveTarget: false,
                                     hideAutomatically: false,
                                     delegate: nil)
            }
        }
    }

}
