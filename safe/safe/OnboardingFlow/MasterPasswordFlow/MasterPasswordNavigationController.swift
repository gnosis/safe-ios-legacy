//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

final class MasterPasswordNavigationController: UINavigationController {

    static func create(_ root: UIViewController) -> MasterPasswordNavigationController {
        let nav = StoryboardScene.MasterPassword.initialScene.instantiate()
        nav.pushViewController(root, animated: false)
        return nav
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        makeNavBarTransparent()
    }

    func makeNavBarTransparent() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
    }

}
