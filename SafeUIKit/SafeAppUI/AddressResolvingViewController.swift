//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit
import SafeUIKit
import MultisigWalletApplication

protocol AddressResolvingViewController: class {

    var addressDetailView: AddressDetailView { get }
    var navigationItem: UINavigationItem { get }

}

extension AddressResolvingViewController {

    func reverseResolveAddress(_ address: String) {
        assert(Thread.isMainThread)
        navigationItem.titleView = LoadingTitleView()
        DispatchQueue.global().async { [weak self] in
            let name: String?
            do {
                name = try ApplicationServiceRegistry.walletService.reverseResolve(address: address)
                if name == nil {
                    ApplicationServiceRegistry.logger.info("ENS name not found for \(address)")
                }
            } catch {
                name = nil
                ApplicationServiceRegistry.logger.info("ENS reverse resolution error: \(error)")
            }
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.navigationItem.titleView = nil
                UIView.animate(withDuration: 0.2) { [unowned self] in
                    self.addressDetailView.name = name
                }
            }
        }
    }

}
