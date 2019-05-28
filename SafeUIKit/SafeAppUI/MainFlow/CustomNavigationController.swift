//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

/// Navigation controller that updates status bar style based on current child view controller
class CustomNavigationController: UINavigationController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return visibleViewController?.preferredStatusBarStyle ?? .default
    }

}
