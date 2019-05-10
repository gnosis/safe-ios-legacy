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
    var paymentToken: TokenData!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Strings.title

        tableView.backgroundColor = ColorName.paleGrey.color
        let bundle = Bundle(for: PaymentMethodViewController.self)
        tableView.register(UINib(nibName: "PaymentMethodHeaderView", bundle: bundle),
                           forHeaderFooterViewReuseIdentifier: "PaymentMethodHeaderView")
        tableView.register(UINib(nibName: "BasicTableViewCell", bundle: Bundle(for: BasicTableViewCell.self)),
                           forCellReuseIdentifier: "BasicTableViewCell")
        tableView.rowHeight = BasicTableViewCell.tokenDataCellHeight
        tableView.separatorStyle = .none

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(updateBalances), for: .valueChanged)
        tableView.refreshControl = refreshControl

        ApplicationServiceRegistry.walletService.subscribeOnTokensUpdates(subscriber: self)
        updateData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(MenuTrackingEvent.feePaymentMethod)
    }

    @objc func updateBalances() {
        DispatchQueue.global().async {
            ApplicationServiceRegistry.walletService.syncBalances()
        }
    }

    private func updateData() {
        precondition(Thread.isMainThread)
        tokens = ApplicationServiceRegistry.walletService.paymentTokens()
        paymentToken = ApplicationServiceRegistry.walletService.feePaymentTokenData
        self.tableView.reloadData()
        self.tableView.refreshControl?.endRefreshing()
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
        cell.accessoryView = tokenData == paymentToken ? checkmarkImageView() : emptyImageView()
        cell.rightTextLabel.text! += "\t" // padding
        return cell
    }

    private func checkmarkImageView() -> UIImageView {
        let checkmarkImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 13))
        checkmarkImageView.contentMode = .scaleAspectFit
        checkmarkImageView.image = Asset.checkmark.image
        return checkmarkImageView
    }

    private func emptyImageView() -> UIImageView {
        return UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 13))
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        ApplicationServiceRegistry.walletService.changePaymentToken(tokens[indexPath.row])
        updateData()
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "PaymentMethodHeaderView")
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return PaymentMethodHeaderView.height
    }

}

extension PaymentMethodViewController: EventSubscriber {

    func notify() {
        DispatchQueue.main.async {
            self.updateData()
        }
    }

}
