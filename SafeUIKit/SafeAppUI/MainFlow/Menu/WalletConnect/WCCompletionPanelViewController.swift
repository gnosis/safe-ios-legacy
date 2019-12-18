//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

// Consists of an overlay panel indicating completion of the wallet connect flow.
// The class is implemented as it is for simplicity.
class WCCompletionPanelViewController: UIViewController {

    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var panelContentView: UIVisualEffectView!
    private var autoDismissTimeout: TimeInterval?

    static func create() -> WCCompletionPanelViewController {
        WCCompletionPanelViewController(nibName: "WCCompletionPanelViewController",
                                        bundle: Bundle(for: WCCompletionPanelViewController.self))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        panelContentView.layer.cornerRadius = 16
        panelContentView.clipsToBounds = true
        textLabel.text = LocalizedString("return_to_dapp", comment: "Go back")
        textLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        textLabel.textColor = ColorName.darkBlue.color
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(WCTrackingEvent.completed)
        scheduleAutoDismiss()
    }

    private func scheduleAutoDismiss() {
        guard let timeout = autoDismissTimeout else { return }
        Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }
    }

    func present(from presenting: UIViewController, dismissAfter timeout: TimeInterval = 2) {
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        autoDismissTimeout = timeout
        presenting.definesPresentationContext = true
        presenting.present(self, animated: true)
    }

    @IBAction func didTapBackground(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
