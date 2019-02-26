//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeAppUI
import Common
import BigInt
import ReplaceBrowserExtensionFacade

class RBEIntroDemoViewController: UIViewController {

    var driver: RBEIntroBackendDemoDriver!
    var user: RBEIntroUser!
    var vc: RBEIntroViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
//         play() // uncomment for scripted screen usage
    }

    func play() {
        driver = RBEIntroBackendDemoDriver()
        vc = RBEIntroViewController.create()
        vc.starter = driver
        user = RBEIntroUser(vc, parent: self)
        user.play()
    }

    @IBAction func push() {
        driver = RBEIntroBackendDemoDriver()
        vc = RBEIntroViewController.create()
        vc.starter = driver

        navigationController?.pushViewController(vc, animated: true)
    }
}

class RBEIntroUser {

    weak var vc: RBEIntroViewController!
    weak var parent: UIViewController!

    var currentDelay: TimeInterval = 0

    init(_ vc: RBEIntroViewController, parent: UIViewController) {
        self.vc = vc
        self.parent = parent
    }

    func play() {
        let defaultDelay: TimeInterval = 4
        showHUD("RBE Intro Demo")
        withDelay(2) {
            self.parent.navigationController?.pushViewController(self.vc, animated: true)
        }
        withDelay(defaultDelay) {
            self.touch(self.vc.retryButtonItem)
        }
        withDelay(defaultDelay) {
            self.touch(self.vc.retryButtonItem)
        }
        withDelay(defaultDelay) {
            self.touch(self.vc.startButtonItem)
        }
        withDelay(defaultDelay) {
            let alert = self.vc.presentedViewController as! UIAlertController
            alert.dismiss(animated: true, completion: nil)
        }
        withDelay(1) {
            self.touch(self.vc.startButtonItem)
        }
        withDelay(3) {
            self.showHUD("The End!")
        }
    }

    func showHUD(_ text: String, duration: TimeInterval = 2.0) {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 22)
        label.translatesAutoresizingMaskIntoConstraints = false
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)


        guard let window = UIApplication.shared.keyWindow else { return }
        window.addSubview(view)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            view.widthAnchor.constraint(equalTo: label.widthAnchor, constant: 50),
            view.heightAnchor.constraint(equalTo: label.heightAnchor, constant: 50),
            view.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: window.centerYAnchor)
            ])

        view.alpha = 0
        UIView.animate(withDuration: 0.5) {
            view.alpha = 1
        }

        UIView.animate(withDuration: 0.5, delay: duration, options: [], animations: {
            view.alpha = 0
        }) { _ in
            view.removeFromSuperview()
        }
    }

    func withDelay(_ delay: TimeInterval, block: @escaping () -> Void) {
        currentDelay += delay
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(currentDelay * 1000.0)), execute: block)
    }

    func touch(_ item: UIBarButtonItem) {
        guard let view = item.value(forKey: "view") as? UIView else { return }
        touch(view)
        guard let action = item.action, let target = item.target else { return }
        UIApplication.shared.sendAction(action, to: target, from: item, for: nil)
    }

    func touch(_ view: UIView) {
        guard let window = UIApplication.shared.keyWindow else { return }
        let touch = self.makeTouch()
        touch.center = view.convert(view.center, to: nil)
        window.addSubview(touch)
    }

    func makeTouch() -> UIView {
        let image = UIImage(named: "touch-icon", in: Bundle(for: RBEIntroUser.self), compatibleWith: nil)?
            .withAlignmentRectInsets(UIEdgeInsets(top: 4, left: 4, bottom: 21, right: 4))
        let view = UIImageView(image: image)
        view.sizeToFit()
        view.contentMode = .scaleAspectFit
        view.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
        UIView.animate(withDuration: 1, animations: {
            view.alpha = 0
        }) { _ in
            view.removeFromSuperview()
        }
        return view
    }

}

class RBEIntroBackendDemoDriver: RBEStarter {

    var requestDelay: TimeInterval = 1.5

    enum EstimationSteps: Int {
        case genericError
        case balanceError
        case ok
    }

    var estimationStep: EstimationSteps = .genericError
    var startingStep: StartingSteps = .error

    enum StartingSteps: Int {
        case error
        case ok
    }

    func create() -> RBETransactionID {
        return "SomeTransactioID"
    }

    func estimate(transaction: RBETransactionID) -> RBEEstimationResult {
        usleep(UInt32(requestDelay) * UInt32(USEC_PER_SEC))
        switch estimationStep {
        case .genericError:
            estimationStep = .balanceError
            return RBEEstimationResult(feeCalculation: nil,
                                       error: NSError(domain: NSURLErrorDomain,
                                                      code: NSURLErrorTimedOut,
                                                      userInfo: [NSLocalizedDescriptionKey: "Request timed out"]))
        case .balanceError:
            estimationStep = .ok
            return RBEEstimationResult(feeCalculation: RBEFeeCalculationData(currentBalance: TokenData.Ether.withBalance(BigInt(1e18)),
                                                                             networkFee: TokenData.Ether.withBalance(BigInt(-2e18)),
                                                                             balance: TokenData.Ether.withBalance(BigInt(-1e18))),
                                       error: FeeCalculationError.insufficientBalance)
        case .ok:
            return RBEEstimationResult(feeCalculation: RBEFeeCalculationData(currentBalance: TokenData.Ether.withBalance(BigInt(3e18)),
                                                                             networkFee: TokenData.Ether.withBalance(BigInt(-2e18)),
                                                                             balance: TokenData.Ether.withBalance(BigInt(1e18))),
                                       error: nil)
        }
    }

    func start(transaction: RBETransactionID) throws {
        usleep(UInt32(requestDelay) * UInt32(USEC_PER_SEC))
        switch startingStep {
        case .error:
            startingStep = .ok
            throw NSError(domain: NSURLErrorDomain,
                          code: NSURLErrorTimedOut,
                          userInfo: [NSLocalizedDescriptionKey: "Request timed out"])
        case .ok:
            return
        }
    }

}
