//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication

class BaseInputViewController: UIViewController, EventSubscriber {

    var activityIndicatorItem: UIBarButtonItem!
    let activityIndicatorView = UIActivityIndicatorView(style: .gray)
    @IBOutlet var nextButtonItem: UIBarButtonItem!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!

    let headerStyle = HeaderStyle.contentHeader

    var headerText: String {
        preconditionFailure("Not implemented")
    }

    var actionFailureMessageFormat: String {
        preconditionFailure("Not implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        nextButtonItem.title = LocalizedString("new_safe.next", comment: "Next")
        activityIndicatorItem = UIBarButtonItem(customView: activityIndicatorView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.attributedText = .header(from: headerText, style: headerStyle)
        disableNextAction()
    }

    func disableNextAction() {
        nextButtonItem.isEnabled = false
    }

    func enableNextAction() {
        nextButtonItem.isEnabled = true
    }

    func startActivityIndicator() {
        navigationItem.setRightBarButton(activityIndicatorItem, animated: true)
        activityIndicatorView.startAnimating()
    }

    func stopActivityIndicator() {
        activityIndicatorView.stopAnimating()
        navigationItem.setRightBarButton(nextButtonItem, animated: true)
    }

    func show(error: Error) {
        let message = String(format: actionFailureMessageFormat, error.localizedDescription)
        let controller = InputFailedAlertController.create(message: message) { /* empty */ }
        present(controller, animated: true)
    }

    @IBAction func next(_ sender: Any) {}

    func notify() {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.stopActivityIndicator()
            self.enableNextAction()
        }
    }

}

class InputFailedAlertController: SafeAlertController {

    private struct Strings {

        static let title = LocalizedString("recovery.address.failed_alert.title",
                                           comment: "Recovery address validation failed alert's title")
        static let okTitle = LocalizedString("recovery.address.failed_alert.ok", comment: "OK button title")

    }

    static func create(message: String,
                       ok: @escaping () -> Void) -> InputFailedAlertController {
        let controller = InputFailedAlertController(title: Strings.title,
                                                    message: message,
                                                    preferredStyle: .alert)
        let okAction = UIAlertAction.create(title: Strings.okTitle, style: .cancel, handler: wrap(closure: ok))
        controller.addAction(okAction)
        return controller
    }

}
