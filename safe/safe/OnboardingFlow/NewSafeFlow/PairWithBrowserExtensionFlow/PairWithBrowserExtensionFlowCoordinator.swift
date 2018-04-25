//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

typealias PairWithBrowserExtensionCompletion = (_ extensionAddress: String) -> Void

final class PairWithBrowserExtensionFlowCoordinator: FlowCoordinator {

    private let completion: PairWithBrowserExtensionCompletion

    init(completion: @escaping PairWithBrowserExtensionCompletion) {
        self.completion = completion
    }

    override func flowStartController() -> UIViewController {
        return PairWithBrowserExtensionViewController.create(delegate: self)
    }

}

extension PairWithBrowserExtensionFlowCoordinator: PairWithBrowserDelegate {

    func didPair(_ extensionAddress: String) {
        completion(extensionAddress)
    }

}
