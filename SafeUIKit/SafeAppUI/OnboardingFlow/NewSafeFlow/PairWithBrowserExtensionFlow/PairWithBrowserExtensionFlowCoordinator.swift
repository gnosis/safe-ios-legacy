//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

typealias PairWithBrowserExtensionCompletion = (_ extensionAddress: String) -> Void

final class PairWithBrowserExtensionFlowCoordinator: FlowCoordinator {

    private let address: String?
    private(set) var extensionAddress: String?

    init(address: String?, rootViewController: UIViewController? = nil) {
        self.address = address
        super.init(rootViewController: rootViewController)
    }

    override func setUp() {
        super.setUp()
        pushController(PairWithBrowserExtensionViewController.create(delegate: self, extensionAddress: address))
    }

}

extension PairWithBrowserExtensionFlowCoordinator: PairWithBrowserDelegate {

    func didPair(_ extensionAddress: String) {
        self.extensionAddress = extensionAddress
        exitFlow()
    }

}
