//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import IdentityAccessApplication

typealias PairWithBrowserExtensionCompletion = () -> Void

final class PairWithBrowserExtensionFlowCoordinator: FlowCoordinator {

    private let completion: PairWithBrowserExtensionCompletion?
    private let draftSafe: DraftSafe?

    init(draftSafe: DraftSafe?, completion: PairWithBrowserExtensionCompletion? = nil) {
        self.draftSafe = draftSafe
        self.completion = completion
    }

    override func flowStartController() -> UIViewController {
        return PairWithBrowserExtensionViewController.create(delegate: self)
    }

}

extension PairWithBrowserExtensionFlowCoordinator: PairWithBrowserDelegate {

    func didPair(_ extensionAddress: String) {}

}
