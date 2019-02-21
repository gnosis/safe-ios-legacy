//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import ReplaceBrowserExtensionFacade

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
    var feeCalculation: EthFeeCalculation {
        get {
            return feeCalculationView.calculation as! EthFeeCalculation
        }
        set {
            feeCalculationView.calculation = newValue

        }
    }
    public var transactionID: RBETransactionID?
    public var starter: RBEStarter?
    let formatter = TokenNumberFormatter()

    @IBOutlet weak var feeCalculationView: FeeCalculationView!

    struct Strings {
        var start = LocalizedString("navigation.start", comment: "Start")
        var back = LocalizedString("navigation.back", comment: "Back")
    }

    var strings = Strings()

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
        startButtonItem = UIBarButtonItem(title: strings.start, style: .done, target: self, action: #selector(start))
        backButtonItem = UIBarButtonItem(title: strings.back, style: .plain, target: self, action: #selector(back))
        retryButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(retry))
        formatter.displayedDecimals = 5
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        transition(to: state)
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
        feeCalculation = EthFeeCalculation()
        guard let data = calculationData else { return }
        formatter.tokenSymbol = data.currentBalance.code
        feeCalculation.currentBalance.set(value: formatter.string(from: data.currentBalance.balance!))
        feeCalculation.networkFee.set(value: formatter.string(from: data.networkFee.balance!))
        feeCalculation.balance.set(value: formatter.string(from: data.balance.balance!))
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

    // duplicated with showTransactionFeeInfo(0
    @objc public func showNetworkFeeInfo() {
        let alert = UIAlertController(title: LocalizedString("network_fee.alert.title",
                                                             comment: "Transaction fee"),
                                      message: LocalizedString("network_fee.alert.message",
                                                               comment: "Explanatory message"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizedString("network_fee.alert.ok",
                                                             comment: "Ok"), style: .default))
        present(alert, animated: true)
    }

}
