//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication
import Common

protocol CreationFeeIntroDelegate: class {
    func creationFeeIntroPay()
    func creationFeeIntroChangePaymentMethod(estimations: [TokenData])
    /// Will be called on a background thread. Load the fee estimations and return them.
    func creationFeeLoadEstimates() -> [TokenData]
    func creationFeeNetworkFeeAlert() -> UIAlertController
}

class OnboardingCreationFeeIntroViewController: BasePaymentMethodViewController {

    var titleText: String?
    var screenTrackingEvent: Trackable?

    private weak var delegate: CreationFeeIntroDelegate!

    static func create(delegate: CreationFeeIntroDelegate) -> OnboardingCreationFeeIntroViewController {
        let controller = OnboardingCreationFeeIntroViewController()
        controller.delegate = delegate
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.allowsSelection = false
        navigationItem.titleView = SafeLabelTitleView.onboardingTitleView(text: titleText)
    }

    override func viewWillAppear(_ animated: Bool) {
        // parent triggers updateData() to fetch results from the server
        super.viewWillAppear(animated)
        // update on view will appear in case the selected token is changed from the PaymentMethod screen
        update(with: self.tokens)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let event = screenTrackingEvent {
            trackEvent(event)
        }
    }

    override func updateData() {
        showLoadingTitleIfNeeded()
        DispatchQueue.global().async {
            let estimations = self.delegate!.creationFeeLoadEstimates()
            DispatchQueue.main.async { [weak self] in
                self?.update(with: estimations)
                self?.hideLoadingTitleIfNeeded()
            }
        }
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

    private func showLoadingTitleIfNeeded() {
        if navigationItem.titleView is LoadingTitleView { return }
        navigationItem.titleView = LoadingTitleView()
    }

    private func hideLoadingTitleIfNeeded() {
        if navigationItem.titleView is SafeLabelTitleView { return }
        navigationItem.titleView = SafeLabelTitleView.onboardingTitleView(text: titleText)
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicTableViewCell",
                                                 for: indexPath) as! BasicTableViewCell
        cell.configure(tokenData: paymentToken,
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
            let alert = self.delegate!.creationFeeNetworkFeeAlert()
            self.present(alert, animated: true)
        }
        return view
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PaymentMethodFooterView")
            as! PaymentMethodFooterView
        view.onPay = { [unowned self] in
            self.delegate.creationFeeIntroPay()
        }
        view.onChange = { [unowned self] in
            self.delegate.creationFeeIntroChangePaymentMethod(estimations: self.tokens)
        }
        view.setPaymentMethodCode(paymentToken.code)
        return view
    }

}
