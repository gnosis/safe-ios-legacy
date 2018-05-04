//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

typealias PairWithBrowserExtensionCompletion = (_ extensionAddress: String) -> Void

final class PairWithBrowserExtensionFlowCoordinator: FlowCoordinator {

    private let address: String?
    private let completion: PairWithBrowserExtensionCompletion

    init(address: String?, completion: @escaping PairWithBrowserExtensionCompletion) {
        self.address = address
        self.completion = completion
    }

    override func flowStartController() -> UIViewController {
        return PairWithBrowserExtensionViewController.create(delegate: self, extensionAddress: address)
    }

}

extension PairWithBrowserExtensionFlowCoordinator: PairWithBrowserDelegate {

    func didPair(_ extensionAddress: String) {
        completion(extensionAddress)
    }

}
