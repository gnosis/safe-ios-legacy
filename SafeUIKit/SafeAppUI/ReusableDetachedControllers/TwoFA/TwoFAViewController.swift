//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication
import Common
import SafariServices

@objc
public protocol TwoFAViewControllerDelegate: class {

    func twoFAViewController(_ controller: TwoFAViewController, didScanAddress address: String, code: String) throws
    func twoFAViewControllerDidFinish()

    @objc
    optional func twoFAViewControllerDidSkipPairing()

}

public final class TwoFAViewController: CardViewController {

    enum Strings {
        static let downloadExtension = LocalizedString("ios_open_be_link_text",
                                                       comment: "'Download the' Gnosis Safe Chrome browser exntension.")
        static let chromeExtension = LocalizedString("ios_open_be_link_substring",
                                                     comment: "Download the 'Gnosis Safe Chrome browser exntension.'")
        static let scanQRCode = LocalizedString("install_browser_extension",
                                                comment: "Scan its QR code.")
        static let skipSetup = LocalizedString("skip_setup_later",
                                               comment: "Skip button text")
        static let scan = LocalizedString("scan",
                                          comment: "Scan button title in extension setup screen")
        static let browserExtensionExpired = LocalizedString("ios_be_error_network",
                                                             comment: "Browser Extension Expired Message")
        static let networkError = LocalizedString("ios_be_error_expired",
                                                  comment: "Network error message")
        static let invalidCode = LocalizedString("ios_be_error_invalid",
                                                 comment: "Invalid extension code")
    }

    weak var delegate: TwoFAViewControllerDelegate?

    private var logger: Logger {
        return MultisigWalletApplication.ApplicationServiceRegistry.logger
    }
    private var walletService: WalletApplicationService {
        return MultisigWalletApplication.ApplicationServiceRegistry.walletService
    }
    private var ethereumService: EthereumApplicationService {
        return MultisigWalletApplication.ApplicationServiceRegistry.ethereumService
    }
    let twoFAView = TwoFAView()

    var downloadExtensionEnabled = true
    var scanBarButtonItem: ScanBarButtonItem!
    private var activityIndicator: UIActivityIndicatorView!
    var backButtonItem: UIBarButtonItem!
    private var didCancel = false

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

    public var screenTrackingEvent: Trackable?
    public var scanTrackingEvent: Trackable?

    public static func create(delegate: TwoFAViewControllerDelegate?) -> TwoFAViewController {
        let controller = TwoFAViewController(nibName: String(describing: CardViewController.self),
                                             bundle: Bundle(for: CardViewController.self))
        controller.delegate = delegate
        return controller
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        backButtonItem = UIBarButtonItem.backButton(target: self, action: #selector(back))

        embed(view: twoFAView, inCardSubview: cardHeaderView)
        subtitleLabel.isHidden = true
        subtitleDetailLabel.isHidden = true
        cardBodyView.isHidden = true
        cardSeparatorView.isHidden = true

        configureScanButton()
        configureActivityIndicator()
        configureStepsLabels()
        configureSkipButton()
        updateTexts()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let event = screenTrackingEvent {
            trackEvent(event)
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didCancel = false
        setCustomBackButton(backButtonItem)
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
        twoFAView.headerLabel.text = screenHeader
        twoFAView.body1Label.text = descriptionText
    }

    func updateSkipButton() {
        footerButton?.isHidden = hidesSkipButton
    }

    @objc func back() {
        didCancel = true
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
        footerButton.setTitle(Strings.skipSetup, for: .normal)
        footerButton.isHidden = hidesSkipButton
        footerButton.addTarget(self, action: #selector(skipPairing(_:)), for: .touchUpInside)
    }

    private func configureStepsLabels() {
        let body2Text = NSMutableAttributedString(string: Strings.downloadExtension)
        let range = body2Text.mutableString.range(of: Strings.chromeExtension)
        body2Text.addAttribute(.foregroundColor, value: ColorName.aquaBlue.color, range: range)
        body2Text.addLinkIcon()
        twoFAView.body2Label.attributedText = body2Text
        twoFAView.body2Label.isUserInteractionEnabled = true
        twoFAView.body2Label.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                         action: #selector(downloadBrowserExtension)))
        twoFAView.body3Label.text = Strings.scanQRCode
    }

    @objc private func downloadBrowserExtension() {
        guard downloadExtensionEnabled else { return }
        let safariVC = SFSafariViewController(url: walletService.configuration.chromeExtensionURL)
        safariVC.modalPresentationStyle = .popover
        present(safariVC, animated: true)
    }

    private func disableButtons() {
        scanBarButtonItem?.isEnabled = false
        footerButton?.isEnabled = false
        downloadExtensionEnabled = false
    }

    private func enableButtons() {
        scanBarButtonItem?.isEnabled = true
        footerButton?.isEnabled = true
        downloadExtensionEnabled = true
    }

    private func processValidCode(_ code: String) {
        let address = scanBarButtonItem.scanValidatedConverter!(code)!
        do {
            try self.delegate?.twoFAViewController(self, didScanAddress: address, code: code)
            if self.didCancel { return }
            trackEvent(OnboardingTrackingEvent.twoFAScanSuccess)
            DispatchQueue.main.async {
                self.delegate?.twoFAViewControllerDidFinish()
            }
        } catch let e {
            if self.didCancel { return }
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
        delegate?.twoFAViewControllerDidSkipPairing?()
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

extension TwoFAViewController: ScanBarButtonItemDelegate {

    public func scanBarButtonItemWantsToPresentController(_ controller: UIViewController) {
        present(controller, animated: true)
        if let scannerTrackingView = scanTrackingEvent {
            trackEvent(scannerTrackingView)
        }
    }

    public func scanBarButtonItemDidScanValidCode(_ code: String) {
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
