//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

final class SafeAddressViewController: UIViewController {

    enum Strings {
        static let title = LocalizedString("safe_address.title", comment: "Title for Address Details screen.")
    }

    static func create() -> SafeAddressViewController {
        return StoryboardScene.Main.safeAddressViewController.instantiate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Strings.title
    }

}
