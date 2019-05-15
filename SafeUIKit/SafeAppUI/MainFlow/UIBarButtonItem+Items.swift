//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

extension UIBarButtonItem {

    static func backButton(target: Any? = nil, action: Selector? = nil) -> UIBarButtonItem {
        return UIBarButtonItem(title: LocalizedString("back", comment: "Back"),
                               style: .plain,
                               target: target,
                               action: action)
    }

    static func menuButton(target: Any? = nil, action: Selector? = nil) -> UIBarButtonItem {
        return UIBarButtonItem(title: LocalizedString("menu", comment: "Menu button title"),
                               style: .done,
                               target: target,
                               action: action)
    }

}
