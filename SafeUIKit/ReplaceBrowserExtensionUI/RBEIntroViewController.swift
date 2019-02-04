//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

public class RBEIntroViewController: UIViewController {

    var startButtonItem: UIBarButtonItem!
    var backButtonItem: UIBarButtonItem!
    var retryButtonItem: UIBarButtonItem!

    var state: State = LoadingState()
    var calculationData: CalculationData?
    var feeCalculation: EthFeeCalculation {
        get {
            return feeCalculationView.calculation as! EthFeeCalculation
        }
        set {
            feeCalculationView.calculation = newValue
        }
    }

    @IBOutlet weak var feeCalculationView: FeeCalculationView!

    struct Strings {
        var start = LocalizedString("navigation.start", comment: "Start")
        var back = LocalizedString("navigation.back", comment: "Back")
        var retry = LocalizedString("navigation.retry", comment: "Retry")
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
        startButtonItem = UIBarButtonItem(title: strings.start, style: .done, target: nil, action: nil)
        let chevronImage = UIImage(named: "Chevron", in: Bundle(for: RBEIntroViewController.self), compatibleWith: nil)
        let chevronHighlighted = UIImage(named: "Chevron-highlighted", in: Bundle(for: RBEIntroViewController.self), compatibleWith: nil)
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
        button.setTitle(strings.back, for: .normal)
        button.setTitleColor(button.tintColor, for: .normal)
        button.setTitleColor(button.tintColor.withAlphaComponent(0.5), for: .highlighted)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.setImage(chevronImage, for: .normal)
        button.setImage(chevronHighlighted, for: .highlighted)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -9.5, bottom: -1, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: -0.5, left: -0.5, bottom: 0, right: 0)
        let container = UIView()
        button.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(button)
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 44),
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: -2),
            button.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            container.heightAnchor.constraint(equalTo: button.heightAnchor),
            container.widthAnchor.constraint(equalTo: button.widthAnchor,
                                             constant: (chevronImage?.size.width ?? 0) - button.imageEdgeInsets.left)])
        container.translatesAutoresizingMaskIntoConstraints = false
        backButtonItem = UIBarButtonItem(customView: container)
//        backButtonItem = UIBarButtonItem(title: strings.back,
//                                         style: .plain,
//                                         target: self,
//                                         action: #selector(back))
        retryButtonItem = UIBarButtonItem(title: strings.retry, style: .done, target: nil, action:  nil)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        transition(to: state)
    }

    func transition(to newState: State) {
        state = newState
        newState.didEnter(controller: self)
    }

    func reloadData() {
        feeCalculation = EthFeeCalculation()
        guard let data = calculationData else { return }
        let formatter = TokenNumberFormatter()
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
        navigationController?.popViewController(animated: true)
    }

    public func didLoad() {
        state.didLoad(controller: self)
    }

    public func start() {
        state.start(controller: self)
    }

    public func didStart() {
        state.didStart(controller: self)
    }

    public func retry() {
        state.retry(controller: self)
    }

}
