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
        nextButtonItem.title = LocalizedString("next", comment: "Next")
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
        present(UIAlertController.operationFailed(message: message), animated: true)
    }

    @IBAction func next(_ sender: Any) {}

    func notify() {
        DispatchQueue.main.async {
            self.stopActivityIndicator()
            self.enableNextAction()
        }
    }

}
