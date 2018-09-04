//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

class MainContentViewController: SegmentBarController {

    let tokensController = TokensTableViewController()
    let transactionsController = TransactionsTableViewController.create()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [tokensController, transactionsController]
        selectedViewController = tokensController
    }

}

extension TokensTableViewController: SegmentController {

    public var segmentItem: SegmentBarItem {
        return SegmentBarItem(title: LocalizedString("main.segment.assets", comment: "Assets tab title"),
                              image: Asset.MainScreenHeader.coins.image)
    }

}

extension TransactionsTableViewController: SegmentController {

    public var segmentItem: SegmentBarItem {
        return SegmentBarItem(title: LocalizedString("main.segment.transactions", comment: "Transactions tab title"),
                              image: Asset.MainScreenHeader.arrows.image)
    }

}
