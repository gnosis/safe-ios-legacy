//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication

final class SafeAddressViewController: UIViewController {

    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var identiconLabel: UILabel!
    @IBOutlet weak var identiconView: IdenticonView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var safeAddressLabel: FullEthereumAddressLabel!
    @IBOutlet weak var qrCodeLabel: UILabel!
    @IBOutlet weak var qrCodeView: QRCodeView!

    enum Strings {
        static let title = LocalizedString("receive_funds", comment: "Receive Funds screen title.")
        static let description = LocalizedString("share_your_address",
                                                 comment: "Description for Receive Funds screen.")
        static let identicon = LocalizedString("ios_identicon", comment: "Identicon label.")
        static let address = LocalizedString("address", comment: "Safe Address label.")
        static let qrCode = LocalizedString("ios_qr_code", comment: "QR Code label.")
    }

    static func create() -> SafeAddressViewController {
        return StoryboardScene.Main.safeAddressViewController.instantiate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTexts()
        configureWrapperView()

        guard let address = ApplicationServiceRegistry.walletService.selectedWalletAddress else { return }
        identiconView.seed = address
        configureQRCode(address)
        safeAddressLabel.address = address
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(MainTrackingEvent.receiveFunds)
    }

    @IBAction func shareAddress(_ sender: Any) {
        guard let address = ApplicationServiceRegistry.walletService.selectedWalletAddress else { return }
        let activityController = UIActivityViewController(activityItems: [address], applicationActivities: nil)
        present(activityController, animated: true)
    }

    private func configureTexts() {
        title = Strings.title
        descriptionLabel.text = Strings.description
        identiconLabel.text = Strings.identicon
        addressLabel.text = Strings.address
        qrCodeLabel.text = Strings.qrCode
    }

    private func configureWrapperView() {
        wrapperView.layer.cornerRadius = 9
        wrapperView.layer.shadowColor = UIColor.black.cgColor
        wrapperView.layer.shadowOffset = CGSize(width: 0, height: 2)
        wrapperView.layer.shadowOpacity = 0.7
    }

    private func configureQRCode(_ address: String) {
        qrCodeView.value = address
        qrCodeView.padding = 12
        qrCodeView.layer.borderWidth = 1
        qrCodeView.layer.borderColor = UIColor.black.cgColor
        qrCodeView.layer.cornerRadius = 9
    }

}
