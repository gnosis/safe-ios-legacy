//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import Common
import SafeUIKit
import MultisigWalletApplication

protocol CreationFeePaymentMethodDelegate: class {
    func creationFeePaymentMethodPay()
}

class CreationFeePaymentMethodViewController: BasicPaymentMethodViewController {

    private weak var delegate: CreationFeePaymentMethodDelegate!
    private var didUpdateOnce = false

    let payButton = StandardButton()

    override var paymentToken: TokenData! {
        didSet {
            updatePayButtonTitle()
        }
    }

    enum Strings {
        static let title = LocalizedString("fee_method", comment: "Fee Payment Method")
        static let headerDescription = LocalizedString("choose_how_to_pay_creation_fee",
                                                       comment: "Choose how to pay the creation fee.")
        static let fee = LocalizedString("fee", comment: "Fee").uppercased()
        static let payWith = LocalizedString("pay_with", comment: "Pay with %@")
    }

    static func create(delegate: CreationFeePaymentMethodDelegate,
                       estimations: [TokenData]) -> CreationFeePaymentMethodViewController {
        let controller = CreationFeePaymentMethodViewController()
        controller.delegate = delegate
        controller.tokens = estimations
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if tokens.isEmpty {
            navigationItem.titleView = LoadingTitleView()
        } else {
            title = Strings.title
        }
        addPayButton()
    }

    private func addPayButton() {
        payButton.style = .filled
        payButton.addTarget(self, action: #selector(pay), for: .touchUpInside)
        payButton.translatesAutoresizingMaskIntoConstraints = false
        payButton.isHidden = true
        view.addSubview(payButton)
        NSLayoutConstraint.activate([
            payButton.heightAnchor.constraint(equalToConstant: 56),
            payButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            payButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            payButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)])
    }

    private func updatePayButtonTitle() {
        payButton.isHidden = false
        payButton.setTitle(String(format: Strings.payWith, paymentToken.code), for: .normal)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(OnboardingTrackingEvent.createSafePaymentMethod)
    }

    override func registerHeaderAndFooter() {
        let bundle = Bundle(for: PaymentMethodHeaderView.self)
        tableView.register(UINib(nibName: "PaymentMethodHeaderView", bundle: bundle),
                           forHeaderFooterViewReuseIdentifier: "PaymentMethodHeaderView")
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = PaymentMethodHeaderView.estimatedHeight
    }

    override func updateData() {
        if didUpdateOnce || tokens.isEmpty {
            DispatchQueue.global().async {
                let estimations = ApplicationServiceRegistry.walletService.estimateSafeCreation()
                DispatchQueue.main.async { [weak self] in
                    self?.hideLoadingTitleIfNeeded()
                    self?.update(with: estimations)
                }
            }
        } else {
            paymentToken = ApplicationServiceRegistry.walletService.feePaymentTokenData
            tableView.reloadData()
        }
        didUpdateOnce = true
    }

    private func hideLoadingTitleIfNeeded() {
        guard navigationItem.titleView != nil else { return }
        navigationItem.titleView = nil
        title = Strings.title
    }

    @objc func pay() {
        delegate.creationFeePaymentMethodPay()
    }

    // MARK: - Table view delegate

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PaymentMethodHeaderView")
            as! PaymentMethodHeaderView
        view.updateDescriptionLabel(Strings.headerDescription, withInfo: false)
        view.updateBalanceLabel(Strings.fee)
        return view
    }

}
