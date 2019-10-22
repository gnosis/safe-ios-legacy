//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication

class BaseInputViewController: UIViewController, EventSubscriber {

    var activityIndicatorItem: UIBarButtonItem!

    let activityIndicatorView = UIActivityIndicatorView.medium()

    @IBOutlet var nextButtonItem: UIBarButtonItem!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var backgroundView: BackgroundImageView!

    override var title: String? {
        didSet {
            navigationItem.titleView = SafeLabelTitleView.onboardingTitleView(text: title)
        }
    }

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
        headerLabel.attributedText = NSAttributedString(string: headerText, style: OnboardingHeaderStyle())
        disableNextAction()
        backgroundView?.isWhite = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCustomBackButton()
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
        DispatchQueue.main.async { [unowned self] in
            self.stopActivityIndicator()
            self.enableNextAction()
        }
    }

}

extension UIActivityIndicatorView {

    static func medium() -> UIActivityIndicatorView {
        if #available(iOS 13, *) {
            return UIActivityIndicatorView(style: .medium)
        } else {
            return UIActivityIndicatorView(style: .gray)
        }
    }

}
