//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import IdentityAccessApplication
import MultisigWalletApplication
import Common
import SafariServices

protocol PairWithBrowserDelegate: class {
    func didPair()
}

final class PairWithBrowserExtensionViewController: UIViewController {

    enum Strings {
        static let title = LocalizedString("new_safe.browser_extension.title",
                                           comment: "Title for add browser extension screen")
        static let header = LocalizedString("new_safe.browser_extension.header",
                                            comment: "Header for add browser extension screen")
        static let description = LocalizedString("new_safe.browser_extension.description",
                                                 comment: "Description for add browser extension screen")
        static let downloadExtension = LocalizedString("new_safe.browser_extension.download_chrome_extension",
                                                       comment: "'Download the' Gnosis Safe Chrome browser exntension.")
        static let chromeExtension = LocalizedString("new_safe.browser_extension.chrome_extension_substring",
                                                     comment: "Download the 'Gnosis Safe Chrome browser exntension.'")
        static let scanQRCode = LocalizedString("new_safe.browser_extension.scan_qr",
                                                comment: "Scan its QR code.")
        static let scan = LocalizedString("new_safe.browser_extension.scan",
                                          comment: "Scan button title in extension setup screen")
        static let browserExtensionExpired = LocalizedString("new_safe.browser_extension.expired",
                                                             comment: "Browser Extension Expired Message")
        static let networkError = LocalizedString("new_safe.browser_extension.network_error",
                                                  comment: "Network error message")
        static let invalidCode = LocalizedString("new_safe.browser_extension.invalid_code_error",
                                                 comment: "Invalid extension code")
    }

    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var step1Label: UILabel!
    @IBOutlet weak var step2Label: UILabel!

    private(set) weak var delegate: PairWithBrowserDelegate?
    private var logger: Logger {
        return MultisigWalletApplication.ApplicationServiceRegistry.logger
    }
    private var walletService: WalletApplicationService {
        return MultisigWalletApplication.ApplicationServiceRegistry.walletService
    }
    private var ethereumService: EthereumApplicationService {
        return MultisigWalletApplication.ApplicationServiceRegistry.ethereumService
    }

    var scanBarButtonItem: ScanBarButtonItem!
    private var activityIndicator: UIActivityIndicatorView!

    static func create(delegate: PairWithBrowserDelegate) -> PairWithBrowserExtensionViewController {
        let controller = StoryboardScene.NewSafe.pairWithBrowserExtensionViewController.instantiate()
        controller.delegate = delegate
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Strings.title
        configureScanButton()
        configureActivityIndicator()
        configureWrapperView()
        configureTexts()
    }

    private func configureScanButton() {
        scanBarButtonItem = ScanBarButtonItem(title: Strings.scan)
        scanBarButtonItem.delegate = self
        scanBarButtonItem.scanValidatedConverter = ethereumService.address(browserExtensionCode:)
        addDebugButtons()
        showScanButton()
    }

    private func configureActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        activityIndicator.color = ColorName.aquaBlue.color
    }

    private func configureWrapperView() {
        wrapperView.layer.shadowColor = UIColor.black.cgColor
        wrapperView.layer.shadowOffset = CGSize(width: 0, height: 2)
        wrapperView.layer.shadowOpacity = 0.4
    }

    private func configureTexts() {
        headerLabel.text = Strings.header
        descriptionLabel.text = Strings.description
        configureStepsLabels()
    }

    private func configureStepsLabels() {
        let attrStr = NSMutableAttributedString(string: "1. \(Strings.downloadExtension)")
        let range = attrStr.mutableString.range(of: Strings.chromeExtension)
        attrStr.addAttribute(.foregroundColor, value: ColorName.aquaBlue.color, range: range)
        attrStr.addLinkIcon()
        step1Label.attributedText = attrStr
        step1Label.isUserInteractionEnabled = true
        step1Label.addGestureRecognizer(UITapGestureRecognizer(
            target: self, action: #selector(downloadBrowserExtension)))
        step2Label.text = "2. \(Strings.scanQRCode)"
    }

    @objc private func downloadBrowserExtension() {
        let safariVC = SFSafariViewController(url: URL(string: walletService.chromeExtensionURL)!)
        safariVC.modalPresentationStyle = .popover
        present(safariVC, animated: true)
    }

    private func addBrowserExtensionOwner(code: String) {
        let address = scanBarButtonItem.scanValidatedConverter!(code)!
        do {
            try walletService.addBrowserExtensionOwner(address: address, browserExtensionCode: code)
            DispatchQueue.main.async {
                self.delegate?.didPair()
            }
        } catch WalletApplicationServiceError.validationFailed {
            showError(message: Strings.invalidCode, log: "Invalid browser extension code")
        } catch let error as WalletApplicationServiceError where error == .networkError || error == .clientError {
            showError(message: Strings.networkError, log: "Network Error in pairing")
        } catch WalletApplicationServiceError.exceededExpirationDate {
            showError(message: Strings.browserExtensionExpired, log: "Browser Extension code is expired")
        } catch let e {
            showError(message: Strings.invalidCode, log: "Failed to pair with extension: \(e)")
        }
    }

    private func showActivityIndicator() {
        let activityButton = UIBarButtonItem(customView: activityIndicator)
        activityIndicator.startAnimating()
        navigationItem.rightBarButtonItem = activityButton
    }

    private func showScanButton() {
        navigationItem.rightBarButtonItem = scanBarButtonItem
    }

    private func showError(message: String, log: String) {
        DispatchQueue.main.async {
            self.showScanButton()
            ErrorHandler.showError(message: message, log: log, error: nil)
        }
    }

    // MARK: - Debug Buttons

    private let validCodeTemplate = """
        {
            "expirationDate" : "%@",
            "signature": {
                "v" : 27,
                "r" : "15823297914388465068645274956031579191506355248080856511104898257696315269079",
                "s" : "38724157826109967392954642570806414877371763764993427831319914375642632707148"
            }
        }
        """

    private func addDebugButtons() {
        scanBarButtonItem.addDebugButtonToScannerController(
            title: "Scan Valid Code", scanValue: validCode(timeIntervalSinceNow: 5 * 60))
        scanBarButtonItem.addDebugButtonToScannerController(
            title: "Scan Invalid Code", scanValue: "invalid_code")
        scanBarButtonItem.addDebugButtonToScannerController(
            title: "Scan Expired Code", scanValue: validCode(timeIntervalSinceNow: -5 * 60))
    }

    private func validCode(timeIntervalSinceNow: TimeInterval) -> String {
        let dateStr = DateFormatter.networkDateFormatter.string(from: Date(timeIntervalSinceNow: timeIntervalSinceNow))
        return String(format: validCodeTemplate, dateStr)
    }

}

extension PairWithBrowserExtensionViewController: ScanBarButtonItemDelegate {

    func presentController(_ controller: UIViewController) {
        present(controller, animated: true)
    }

    func didScanValidCode(_ button: ScanBarButtonItem, code: String) {
        showActivityIndicator()
        DispatchQueue.global().async {
            self.addBrowserExtensionOwner(code: code)
        }
    }

}
