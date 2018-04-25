//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import IdentityAccessApplication

protocol PairWithBrowserDelegate: class {
    func didPair(_ extensionAddress: String)
}

final class PairWithBrowserExtensionViewController: UIViewController {

    private var identityService: IdentityApplicationService { return ApplicationServiceRegistry.identityService }
    public private(set) weak var delegate: PairWithBrowserDelegate?

    static func create(delegate: PairWithBrowserDelegate,
                       extensionAddress: String? = nil) -> PairWithBrowserExtensionViewController {
        let controller = StoryboardScene.NewSafe.pairWithBrowserExtensionViewController.instantiate()
        controller.delegate = delegate
        return controller
    }

}
