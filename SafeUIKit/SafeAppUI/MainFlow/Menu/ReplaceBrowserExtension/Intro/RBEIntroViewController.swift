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

    @IBOutlet weak var contentView: IntroContentView!
    @IBOutlet weak var feeCalculationView: FeeCalculationView!

    private enum Strings {
        static let start = LocalizedString("start", comment: "Start")
        static let back = LocalizedString("back", comment: "Back")
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
        backButtonItem = UIBarButtonItem(title: Strings.back, style: .plain, target: self, action: #selector(back))
        retryButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(retry))
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        transition(to: state)
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
        let formatter = TokenNumberFormatter.ERC20Token(code: data.balance.code,
                                                        decimals: data.balance.decimals,
                                                        displayedDecimals: 5)
        feeCalculation.currentBalanceLine.set(value: formatter.string(from: data.currentBalance.balance!))
        feeCalculation.networkFeeLine.set(valueButton: data.networkFee.withNonNegativeBalance())
        feeCalculation.resultingBalanceLine.set(value: formatter.string(from: data.balance.balance!))
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

    @objc public func showNetworkFeeInfo() {
        present(TransactionFeeAlertController.create(), animated: true, completion: nil)
    }

}
