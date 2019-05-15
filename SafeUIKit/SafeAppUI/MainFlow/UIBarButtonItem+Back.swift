//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

extension UIBarButtonItem {

    static func backButton() -> UIBarButtonItem {
        return UIBarButtonItem(title: LocalizedString("back", comment: "Back"),
                               style: .plain,
                               target: nil,
                               action: nil)
    }

}
