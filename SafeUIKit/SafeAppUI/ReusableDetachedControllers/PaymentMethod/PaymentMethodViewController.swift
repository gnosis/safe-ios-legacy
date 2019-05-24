//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication
import Common

class PaymentMethodViewController: BasePaymentMethodViewController {

    enum Strings {
        static let title = LocalizedString("fee_method", comment: "Fee Payment Method")
        enum Alert {
            static let title = LocalizedString("transaction_fee", comment: "Network fee")
            static let description = LocalizedString("transaction_fee_description_token_payment",
                                                     comment: "Fee payment method description")
            static let close = LocalizedString("close", comment: "Close")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Strings.title

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(updateBalances), for: .valueChanged)
        tableView.refreshControl = refreshControl

        ApplicationServiceRegistry.walletService.subscribeOnTokensUpdates(subscriber: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(MenuTrackingEvent.feePaymentMethod)
    }

    override func registerHeaderAndFooter() {
        let bundle = Bundle(for: PaymentMethodHeaderView.self)
        tableView.register(UINib(nibName: "PaymentMethodHeaderView", bundle: bundle),
                           forHeaderFooterViewReuseIdentifier: "PaymentMethodHeaderView")
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = PaymentMethodHeaderView.estimatedHeight
    }

    @objc func updateBalances() {
        DispatchQueue.global().async {
            ApplicationServiceRegistry.walletService.syncBalances()
        }
    }

    override func updateData() {
        precondition(Thread.isMainThread)
        tokens = ApplicationServiceRegistry.walletService.paymentTokens()
        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
    }

    // MARK: - Table view delegate

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PaymentMethodHeaderView")
            as! PaymentMethodHeaderView
        view.onTextSelected = { [unowned self] in
            let alert = UIAlertController(title: Strings.Alert.title,
                                          message: Strings.Alert.description,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Strings.Alert.close, style: .cancel))
            self.present(alert, animated: true)
        }
        return view
    }

}

extension PaymentMethodViewController: EventSubscriber {

    func notify() {
        DispatchQueue.main.async {
            self.updateData()
        }
    }

}
