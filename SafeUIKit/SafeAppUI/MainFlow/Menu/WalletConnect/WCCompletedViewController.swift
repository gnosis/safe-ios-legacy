//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

class WCCompletedViewController: UIViewController {

    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var hudView: UIVisualEffectView!
    private var autoDismissInterval: TimeInterval?

    static func create() -> WCCompletedViewController {
        WCCompletedViewController(nibName: "WCCompletedViewController",
                                  bundle: Bundle(for: WCCompletedViewController.self))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hudView.layer.cornerRadius = 16
        hudView.clipsToBounds = true
        textLabel.text = LocalizedString("return_to_dapp", comment: "Go back")
        textLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        textLabel.textColor = ColorName.darkBlue.color
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(WCTrackingEvent.completed)
        if let timeout = autoDismissInterval {
            Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }

    func scheduleAutoDismiss(after timeout: Double) {
        autoDismissInterval = timeout
    }

    func present(from presenting: UIViewController, dismissAfter timeout: TimeInterval = 2) {
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        scheduleAutoDismiss(after: timeout)
        presenting.definesPresentationContext = true
        presenting.present(self, animated: true)
    }

    @IBAction func didTapBackground(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
