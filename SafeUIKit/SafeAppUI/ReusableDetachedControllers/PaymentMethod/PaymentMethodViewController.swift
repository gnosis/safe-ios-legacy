//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication
import Common

class PaymentMethodViewController: UIViewController {

    enum Strings {
        static let title = LocalizedString("fee_payment_method", comment: "Fee Payment Method")
        enum Alert {
            static let title = LocalizedString("transaction_fee", comment: "Network fee")
            static let description = LocalizedString("transaction_fee_description_token_payment",
                                                     comment: "Fee payment method description")
            static let close = LocalizedString("close", comment: "Close")
        }
    }

    private var tokens = [TokenData]()
    var paymentToken: TokenData!

    let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    var topViewHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Strings.title
        view.backgroundColor = ColorName.paleGrey.color

        let topView = UIView()
        topView.backgroundColor = .white
        topView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topView)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let bundle = Bundle(for: PaymentMethodViewController.self)
        tableView.register(UINib(nibName: "PaymentMethodHeaderView", bundle: bundle),
                           forHeaderFooterViewReuseIdentifier: "PaymentMethodHeaderView")
        tableView.register(UINib(nibName: "BasicTableViewCell", bundle: Bundle(for: BasicTableViewCell.self)),
                           forCellReuseIdentifier: "BasicTableViewCell")
        tableView.rowHeight = BasicTableViewCell.tokenDataCellHeight
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = PaymentMethodHeaderView.estimatedHeight
        tableView.separatorStyle = .none
        view.addSubview(tableView)

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(updateBalances), for: .valueChanged)
        tableView.refreshControl = refreshControl

        topViewHeightConstraint = topView.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            topView.leftAnchor.constraint(equalTo: view.leftAnchor),
            topView.topAnchor.constraint(equalTo: view.topAnchor),
            topView.rightAnchor.constraint(equalTo: view.rightAnchor),
            topViewHeightConstraint,
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])

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
        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
    }

}

// MARK: - Table view data source

extension PaymentMethodViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tokens.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicTableViewCell",
                                                 for: indexPath) as! BasicTableViewCell
        let tokenData = tokens[indexPath.row]
        cell.configure(tokenData: tokenData,
                       displayBalance: true,
                       displayFullName: false,
                       accessoryType: .none)
        cell.accessoryView = tokenData == paymentToken ? checkmarkImageView() : emptyImageView()
        cell.rightTrailingConstraint.constant = 14
        if tokenData.balance ?? 0 == 0 {
            cell.selectionStyle = .none
            cell.leftTextLabel.textColor = ColorName.darkSlateBlue.color.withAlphaComponent(0.5)
            cell.rightTextLabel.textColor = ColorName.darkSlateBlue.color.withAlphaComponent(0.5)
            cell.leftImageView.alpha = 0.5
        }
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

}

// MARK: - Table view delegate

extension PaymentMethodViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let tokenData = tokens[indexPath.row]
        guard tokenData.balance ?? 0 > 0 else { return }
        ApplicationServiceRegistry.walletService.changePaymentToken(tokenData)
        updateData()
    }

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

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentOffset.y <= 0 else { return }
        topViewHeightConstraint.constant = abs(scrollView.contentOffset.y)
    }

}

extension PaymentMethodViewController: EventSubscriber {

    func notify() {
        DispatchQueue.main.async {
            self.updateData()
        }
    }

}
