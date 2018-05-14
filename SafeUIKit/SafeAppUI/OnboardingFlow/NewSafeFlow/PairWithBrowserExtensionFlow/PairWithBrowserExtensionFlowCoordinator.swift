//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

typealias PairWithBrowserExtensionCompletion = (_ extensionAddress: String) -> Void

final class PairWithBrowserExtensionFlowCoordinator: FlowCoordinator {

    private let address: String?
    private(set) var extensionAddress: String?

    init(address: String?) {
        self.address = address
    }

    override func setUp() {
        super.setUp()
        let controller = PairWithBrowserExtensionViewController.create(delegate: self, extensionAddress: address)
        pushController(controller)
    }

}

extension PairWithBrowserExtensionFlowCoordinator: PairWithBrowserDelegate {

    func didPair(_ extensionAddress: String) {
        self.extensionAddress = extensionAddress
        exitFlow()
    }

}
