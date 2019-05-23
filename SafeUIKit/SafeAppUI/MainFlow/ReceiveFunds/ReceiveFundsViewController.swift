//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication

// TODO: refactor and reuse CardViewController
class ReceiveFundsViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var safeLabel: UILabel!
    @IBOutlet weak var identiconView: IdenticonView!
    @IBOutlet weak var safeAddressLabel: FullEthereumAddressLabel!
    @IBOutlet weak var qrCodeView: QRCodeView!

    private var address: String {
        return ApplicationServiceRegistry.walletService.selectedWalletAddress!
    }

    enum Strings {
        static let title = LocalizedString("receive_funds", comment: "Receive Funds")
        static let description = LocalizedString("share_your_address",
                                                 comment: "Description for Receive Funds screen.")
    }

    static func create() -> ReceiveFundsViewController {
        return StoryboardScene.ReceiveFunds.receiveFundsViewController.instantiate()
    }

    @IBAction func share(_ sender: Any) {
        let activityController = UIActivityViewController(activityItems: [address], applicationActivities: nil)
        present(activityController, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Strings.title
        view.backgroundColor = ColorName.paleGrey.color
        headerLabel.textColor = ColorName.battleshipGrey.color
        separatorView.backgroundColor = ColorName.paleLilac.color
        safeLabel.textColor = ColorName.dusk.color
        identiconView.seed = address
        safeAddressLabel.address = address
        safeAddressLabel.hasCopyAddressTooltip = true
        qrCodeView.value = address
        qrCodeView.padding = 12
        qrCodeView.layer.borderWidth = 1
        qrCodeView.layer.borderColor = UIColor.black.cgColor
        qrCodeView.layer.cornerRadius = 9
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(MainTrackingEvent.receiveFunds)
    }

}
