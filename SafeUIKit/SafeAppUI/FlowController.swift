//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit

class FlowController: UIViewController {

    var rootViewController: UIViewController? {
        // to override
        return nil
    }

    override var navigationItem: UINavigationItem {
        children.first?.navigationItem ?? super.navigationItem
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let vc = rootViewController {
            embed(vc)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        children.forEach { $0.viewDidLayoutSubviews() }
    }

    func embed(_ vc: UIViewController) {
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        view.wrapAroundView(vc.view)
        vc.didMove(toParent: self)
    }

}
