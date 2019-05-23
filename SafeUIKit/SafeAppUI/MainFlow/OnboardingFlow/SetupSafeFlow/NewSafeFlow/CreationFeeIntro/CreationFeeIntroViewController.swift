//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication
import Common

protocol CreationFeeIntroDelegate: class {
    func didSelectPay()
    func didSelectChangePaymentMethod()
}

class CreationFeeIntroViewController: BasicPaymentMethodViewController {

    private enum Strings {
        static let title = LocalizedString("create_safe_title", comment: "Create Safe")
        enum Alert {
            static let title = LocalizedString("what_is_safe_creation_fee", comment: "What is the Safe creation fee?")
            static let description = LocalizedString("network_fee_creation", comment: "Safe creation fee description")
            static let close = LocalizedString("close", comment: "Close")
        }
    }

    private weak var delegate: CreationFeeIntroDelegate!

    private var estimations = [TokenData]()
    private var paymentMethodEstimatedTokenData: TokenData {
        let paymentMethodData = ApplicationServiceRegistry.walletService.feePaymentTokenData
        let estimationBalance = estimations.first { $0.address == paymentMethodData.address }?.balance
        return paymentMethodData.withBalance(estimationBalance)
    }

    static func create(delegate: CreationFeeIntroDelegate) -> CreationFeeIntroViewController {
        let controller = CreationFeeIntroViewController()
        controller.delegate = delegate
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = ColorName.paleGrey.color
        tableView.allowsSelection = false
    }

    override func registerHeaderAndFooter() {
        let bundle = Bundle(for: CreationFeeIntroHeaderView.self)
        tableView.register(UINib(nibName: "CreationFeeIntroHeaderView", bundle: bundle),
                           forHeaderFooterViewReuseIdentifier: "CreationFeeIntroHeaderView")
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = CreationFeeIntroHeaderView.estimatedHeight

        tableView.register(UINib(nibName: "PaymentMethodFooterView", bundle: bundle),
                           forHeaderFooterViewReuseIdentifier: "PaymentMethodFooterView")
        tableView.sectionFooterHeight = UITableView.automaticDimension
        tableView.estimatedSectionFooterHeight = PaymentMethodFooterView.estimatedHeight
    }

    override func updateData() {
        showLoadingTitleIfNeeded()
        DispatchQueue.global().async {
            let tokensData = ApplicationServiceRegistry.walletService.estimateSafeCreation()
            DispatchQueue.main.async { [weak self] in
                self?.estimations = tokensData
                self?.tableView.reloadData()
                self?.tableView.refreshControl?.endRefreshing()
                self?.hideLoadingTitleIfNeeded()
            }
        }
    }

    private func showLoadingTitleIfNeeded() {
        guard title == nil else { return }
        navigationItem.titleView = LoadingTitleView()
    }

    private func hideLoadingTitleIfNeeded() {
        guard navigationItem.titleView != nil else { return }
        navigationItem.titleView = nil
        title = Strings.title
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicTableViewCell",
                                                 for: indexPath) as! BasicTableViewCell
        cell.configure(tokenData: paymentMethodEstimatedTokenData,
                       displayBalance: true,
                       displayFullName: false,
                       accessoryType: .none)
        return cell
    }

    // MARK: - Table view delegate

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CreationFeeIntroHeaderView")
            as! CreationFeeIntroHeaderView
        view.onTextSelected = { [unowned self] in
            let alert = UIAlertController(title: Strings.Alert.title,
                                          message: Strings.Alert.description,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Strings.Alert.close, style: .cancel))
            self.present(alert, animated: true)
        }
        return view
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PaymentMethodFooterView")
            as! PaymentMethodFooterView
        view.onChange = {
            self.delegate.didSelectChangePaymentMethod()
        }
        view.onPay = { [unowned self] in
            self.delegate.didSelectPay()
        }
        view.setPaymentMethodCode(paymentMethodEstimatedTokenData.code)
        return view
    }

}