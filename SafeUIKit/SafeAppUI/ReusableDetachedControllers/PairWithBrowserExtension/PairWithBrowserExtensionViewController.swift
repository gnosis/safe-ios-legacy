//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication
import Common
import SafariServices

public protocol PairWithBrowserExtensionViewControllerDelegate: class {

    func pairWithBrowserExtensionViewController(_ controller: PairWithBrowserExtensionViewController,
                                                didScanAddress address: String,
                                                code: String) throws
    func pairWithBrowserExtensionViewControllerDidFinish()
    func pairWithBrowserExtensionViewControllerDidSkipPairing()

}

public final class PairWithBrowserExtensionViewController: UIViewController {

    enum Strings {
        static let downloadExtension = LocalizedString("new_safe.browser_extension.download_chrome_extension",
                                                       comment: "'Download the' Gnosis Safe Chrome browser exntension.")
        static let chromeExtension = LocalizedString("new_safe.browser_extension.chrome_extension_substring",
                                                     comment: "Download the 'Gnosis Safe Chrome browser exntension.'")
        static let scanQRCode = LocalizedString("new_safe.browser_extension.scan_qr",
                                                comment: "Scan its QR code.")
        static let skipSetup = LocalizedString("new_safe.browser_extension.skip",
                                               comment: "Skip button text")
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
    var skipButton: UIButton!
    let skipButtonOffset: CGFloat = 30
    let skipButtonMinimumHeight: CGFloat = 50
    weak var delegate: PairWithBrowserExtensionViewControllerDelegate?

    private var logger: Logger {
        return MultisigWalletApplication.ApplicationServiceRegistry.logger
    }
    private var walletService: WalletApplicationService {
        return MultisigWalletApplication.ApplicationServiceRegistry.walletService
    }
    private var ethereumService: EthereumApplicationService {
        return MultisigWalletApplication.ApplicationServiceRegistry.ethereumService
    }
    var downloadExtensionEnabled = true
    var scanBarButtonItem: ScanBarButtonItem!
    private var activityIndicator: UIActivityIndicatorView!

    public var screenTitle: String? {
        didSet {
            updateTexts()
        }
    }

    public var screenHeader: String? {
        didSet {
            updateTexts()
        }
    }

    public var descriptionText: String? {
        didSet {
            updateTexts()
        }
    }

    public var hidesSkipButton: Bool = false {
        didSet {
            updateSkipButton()
        }
    }

    public static func create(delegate: PairWithBrowserExtensionViewControllerDelegate?)
        -> PairWithBrowserExtensionViewController {
            let controller = StoryboardScene.PairWithBrowserExtension
                .pairWithBrowserExtensionViewController.instantiate()
            controller.delegate = delegate
            return controller
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        configureScanButton()
        configureActivityIndicator()
        configureStepsLabels()
        configureSkipButton()
        updateTexts()
    }

    public func showLoadingTitle() {
        navigationItem.titleView = LoadingTitleView()
    }

    public func hideLoadingTitle() {
        navigationItem.titleView = nil
    }

    func updateTexts() {
        guard isViewLoaded else { return }
        title = screenTitle
        headerLabel.text = screenHeader
        descriptionLabel.text = descriptionText
    }

    func updateSkipButton() {
        skipButton?.isHidden = hidesSkipButton
    }

    func handleError(_ error: Error) {
        guard let err = error as? WalletApplicationServiceError else {
            showError(message: Strings.invalidCode, log: "Failed to pair with extension: \(error)")
            return
        }
        switch err {
        case .validationFailed:
            showError(message: Strings.invalidCode, log: "Invalid browser extension code")
        case .networkError, .clientError:
            showError(message: Strings.networkError, log: "Network Error in pairing")
        case .exceededExpirationDate:
            showError(message: Strings.browserExtensionExpired, log: "Browser Extension code is expired")
        default:
            showError(message: Strings.invalidCode, log: "Failed to pair with extension: \(error)")
        }
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

    private func configureSkipButton() {
        skipButton = UIButton(type: .custom)
        skipButton.setTitleColor(.white, for: .normal)
        skipButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        skipButton.titleLabel?.numberOfLines = 0
        skipButton.titleLabel?.textAlignment = .center
        skipButton.setTitle(Strings.skipSetup, for: .normal)
        skipButton.isHidden = hidesSkipButton
        skipButton.addTarget(self, action: #selector(skipPairing(_:)), for: .touchUpInside)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(skipButton)
        NSLayoutConstraint.activate([
            skipButton.topAnchor.constraint(equalTo: wrapperView.bottomAnchor, constant: skipButtonOffset),
            skipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            skipButton.heightAnchor.constraint(greaterThanOrEqualToConstant: skipButtonMinimumHeight)])
    }

    private func configureStepsLabels() {
        let attrStr = NSMutableAttributedString(string: "1. \(Strings.downloadExtension)")
        let range = attrStr.mutableString.range(of: Strings.chromeExtension)
        attrStr.addAttribute(.foregroundColor, value: ColorName.aquaBlue.color, range: range)
        attrStr.addLinkIcon()
        step1Label.attributedText = attrStr
        step1Label.isUserInteractionEnabled = true
        step1Label.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                               action: #selector(downloadBrowserExtension)))
        step2Label.text = "2. \(Strings.scanQRCode)"
    }

    @objc private func downloadBrowserExtension() {
        guard downloadExtensionEnabled else { return }
        let safariVC = SFSafariViewController(url: walletService.configuration.chromeExtensionURL)
        safariVC.modalPresentationStyle = .popover
        present(safariVC, animated: true)
    }

    private func disableButtons() {
        scanBarButtonItem?.isEnabled = false
        skipButton?.isEnabled = false
        downloadExtensionEnabled = false
    }

    private func enableButtons() {
        scanBarButtonItem?.isEnabled = true
        skipButton?.isEnabled = true
        downloadExtensionEnabled = true
    }

    private func processValidCode(_ code: String) {
        let address = scanBarButtonItem.scanValidatedConverter!(code)!
        do {
            try self.delegate?.pairWithBrowserExtensionViewController(self, didScanAddress: address, code: code)
            DispatchQueue.main.async {
                self.delegate?.pairWithBrowserExtensionViewControllerDidFinish()
            }
        } catch let e {
            DispatchQueue.main.async {
                self.handleError(e)
            }
        }
    }

    private func showError(message: String, log: String) {
        DispatchQueue.main.async {
            ErrorHandler.showError(message: message, log: log, error: nil)
        }
    }

    private func showActivityIndicator() {
        DispatchQueue.main.async {
            let activityButton = UIBarButtonItem(customView: self.activityIndicator)
            self.activityIndicator.startAnimating()
            self.navigationItem.rightBarButtonItem = activityButton
        }
    }

    private func showScanButton() {
        navigationItem.rightBarButtonItem = scanBarButtonItem
    }

    @IBAction func skipPairing(_ sender: Any) {
        delegate?.pairWithBrowserExtensionViewControllerDidSkipPairing()
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

    public func presentController(_ controller: UIViewController) {
        present(controller, animated: true)
    }

    public func didScanValidCode(_ button: ScanBarButtonItem, code: String) {
        disableButtons()
        showLoadingTitle()
        DispatchQueue.global().async {
            self.processValidCode(code)

            DispatchQueue.main.async {
                self.hideLoadingTitle()
                self.enableButtons()
            }
        }
    }

}
