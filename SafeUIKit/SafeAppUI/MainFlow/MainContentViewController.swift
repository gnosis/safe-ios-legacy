//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

class MainContentViewController: SegmentBarController {

    weak var delegate: MainViewControllerDelegate?
    let tokensController = TokensTableViewController()

    var transactionsControllerDelegate: TransactionsTableViewControllerDelegate? {
        get { return transactionsController.delegate }
        set { transactionsController.delegate = newValue }
    }
    let transactionsController = TransactionsTableViewController.create()

    override func viewDidLoad() {
        super.viewDidLoad()
        tokensController.delegate = delegate
        viewControllers = [tokensController, transactionsController]
        selectedViewController = tokensController
    }

    func showTransactionList() {
        selectedViewController = transactionsController
    }

}

extension TokensTableViewController: SegmentController {

    public var segmentItem: SegmentBarItem {
        return SegmentBarItem(title: LocalizedString("assets_capitalized", comment: "Assets tab title"),
                              image: Asset.MainScreenHeader.coins.image)
    }

}

extension TransactionsTableViewController: SegmentController {

    public var segmentItem: SegmentBarItem {
        return SegmentBarItem(title: LocalizedString("transactions_capitalized", comment: "Transactions tab title"),
                              image: Asset.MainScreenHeader.arrows.image)
    }

}
