//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication
import Common

class PaymentMethodViewController: UITableViewController {

    private enum Strings {
        static let title = LocalizedString("fee_payment_method", comment: "Fee Payment Method")
    }

    private var tokens = [TokenData]()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Strings.title

        tableView.backgroundColor = ColorName.paleGrey.color

        tableView.register(UINib(nibName: "BasicTableViewCell", bundle: Bundle(for: BasicTableViewCell.self)),
                           forCellReuseIdentifier: "BasicTableViewCell")
        tableView.rowHeight = BasicTableViewCell.tokenDataCellHeight
        tableView.separatorStyle = .none

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(update), for: .valueChanged)
        tableView.refreshControl = refreshControl

        ApplicationServiceRegistry.walletService.subscribeOnTokensUpdates(subscriber: self)
        notify()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(MenuTrackingEvent.feePaymentMethod)
    }

    @objc private func update() {
        DispatchQueue.global().async {
            ApplicationServiceRegistry.walletService.syncBalances()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tokens.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicTableViewCell",
                                                 for: indexPath) as! BasicTableViewCell
        let tokenData = tokens[indexPath.row]
        cell.configure(tokenData: tokenData,
                       displayBalance: true,
                       displayFullName: false,
                       accessoryType: .none)
        if tokenData == ApplicationServiceRegistry.walletService.feePaymentTokenData {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 11))
        }
        return cell
    }

}

extension PaymentMethodViewController: EventSubscriber {

    func notify() {
        tokens = ApplicationServiceRegistry.walletService.paymentTokens()
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
        }
    }

}
