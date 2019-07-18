//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

extension UIViewController {

    /// Sets custom back bar button item to a view controller immediately below
    /// the receiver. Call this method in the `viewWillAppear()` or on `willMove(toParent:)`
    ///
    /// As per iOS documentation, the `navigationItem.backBarButtonItem` is working only
    /// when it is set on the navigationItem immediately below the current top navigationItem.
    ///
    /// That means, wherever we want to have a custom back button, we must set in on the view controller
    /// that is below the current one in the navigation stack.
    func setCustomBackButton(_ button: UIBarButtonItem = .backButton()) {
        if let nav = navigationController, let thisIndex = nav.viewControllers.lastIndex(of: self), thisIndex >= 1 {
            nav.viewControllers[thisIndex - 1].navigationItem.backBarButtonItem = button
        }
    }

}
