//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication
import Common

public protocol RBEIntroViewControllerDelegate: class {
    func rbeIntroViewControllerDidStart()
}

public class RBEIntroViewController: UIViewController {

    public var startButtonItem: UIBarButtonItem!
    public var backButtonItem: UIBarButtonItem!
    public var retryButtonItem: UIBarButtonItem!

    public weak var delegate: RBEIntroViewControllerDelegate?

    var state: State = LoadingState()
    var calculationData: RBEFeeCalculationData?
    var feeCalculation: OwnerModificationFeeCalculation {
        get {
            return feeCalculationView.calculation as! OwnerModificationFeeCalculation
        }
        set {
            feeCalculationView.calculation = newValue
        }
    }
    public var transactionID: RBETransactionID?
    public var starter: RBEStarter?
    public var screenTrackingEvent: Trackable?

    private var needsEstimation = false

    @IBOutlet weak var contentView: IntroContentView!
    internal var feeCalculationView: FeeCalculationView {
        return contentView.feeCalculationView
    }

    private enum Strings {
        static let start = LocalizedString("start", comment: "Start")
    }

    public static func create() -> RBEIntroViewController {
        return RBEIntroViewController(nibName: "\(self)", bundle: Bundle(for: self))
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        startButtonItem = UIBarButtonItem(title: Strings.start, style: .done, target: self, action: #selector(start))
        backButtonItem = .backButton(target: self, action: #selector(back))
        retryButtonItem = .refreshButton(target: self, action: #selector(retry))
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        needsEstimation = true
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if needsEstimation {
            needsEstimation = false
            transition(to: LoadingState())
        }
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let event = screenTrackingEvent {
            trackEvent(event)
        }
    }

    public override func willMove(toParent parent: UIViewController?) {
        guard let navigationController = parent as? UINavigationController else { return }
        assert(navigationController.topViewController === self, "Unexpected UINavigationController behavior")
        guard navigationController.viewControllers.count > 1,
            let index = navigationController.viewControllers.firstIndex(where: { $0 == self }) else { return }
        state.willPush(controller: self, onTopOf: navigationController.viewControllers[index - 1])
    }

    func transition(to newState: State) {
        state = newState
        newState.didEnter(controller: self)
    }

    func reloadData() {
        feeCalculation = OwnerModificationFeeCalculation()
        guard let data = calculationData else { return }
        feeCalculation.currentBalanceLine.set(value: data.currentBalance)
        feeCalculation.networkFeeLine.set(valueButton: abs(data.networkFee),
                                          target: self,
                                          action: #selector(changePaymentMethod),
                                          roundUp: true)
        feeCalculation.resultingBalanceLine.set(value: data.balance)
        feeCalculation.setBalanceError(nil)
    }

    func setContent(_ content: IntroContentView.Content) {
        if !isViewLoaded {
            loadViewIfNeeded()
        }
        contentView.content = content
        contentView.didLoad()
    }

    func startIndicateLoading() {
        navigationItem.titleView = LoadingTitleView()
    }

    func stopIndicateLoading() {
        navigationItem.titleView = nil
    }

    func showRetry() {
        navigationItem.rightBarButtonItems = [retryButtonItem]
    }

    func showStart() {
        navigationItem.rightBarButtonItems = [startButtonItem]
    }

    func enableStart() {
        startButtonItem.isEnabled = true
    }

    func disableStart() {
        startButtonItem.isEnabled = false
    }

    func enableRetry() {
        retryButtonItem.isEnabled = true
    }

    func disableRetry() {
        retryButtonItem.isEnabled = false
    }

    func showBack() {
        navigationItem.leftBarButtonItems = [backButtonItem]
    }

    // MARK: Actions

    public func handleError(_ error: Error) {
        state.handleError(error, controller: self)
    }

    @objc public func back() {
        state.back(controller: self)
    }

    public func didLoad() {
        state.didLoad(controller: self)
    }

    @objc public func start() {
        state.start(controller: self)
    }

    public func didStart() {
        state.didStart(controller: self)
    }

    @objc public func retry() {
        state.retry(controller: self)
    }

    @objc public func showTransactionFeeInfo() {
        present(UIAlertController.networkFee(), animated: true, completion: nil)
    }

    @objc private func changePaymentMethod() {
        let vc = PaymentMethodViewController()
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension RBEIntroViewController: PaymentMethodViewControllerDelegate {

    func paymentMethodViewControllerDidChangePaymentMethod(_ controller: PaymentMethodViewController) {
        needsEstimation = true
    }

}
