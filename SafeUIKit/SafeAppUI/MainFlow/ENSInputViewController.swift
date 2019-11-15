//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication

protocol ENSInputViewControllerDelegate: class {

    func ensInputViewControllerDidConfirm(_ controller: ENSInputViewController, address: String)

}

class ENSInputViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ensInput: VerifiableInput!
    @IBOutlet weak var ensAddressView: ENSAddressView!
    @IBOutlet weak var confirmBarButton: UIBarButtonItem!

    weak var delegate: ENSInputViewControllerDelegate?
    private var keyboardBehavior: KeyboardAvoidingBehavior!
    private var inputReactionTimer: Timer?

    enum Strings {
        static let title = "Enter ENS Name"
        static let confirm = "Confirm"
        static let placeholder = "Enter ENS Name"
    }

    static func create(delegate: ENSInputViewControllerDelegate) -> ENSInputViewController {
        let controller = StoryboardScene.Main.ensInputViewController.instantiate()
        controller.delegate = delegate
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardBehavior = KeyboardAvoidingBehavior(scrollView: scrollView)
        title = Strings.title
        confirmBarButton.title = Strings.confirm

        ensInput.style = .white
        ensInput.textInput.placeholder = Strings.placeholder
        ensInput.showErrorsOnly = true
        ensInput.delegate = self

        ensAddressView.address = nil
        confirmBarButton.isEnabled = false
        ensInput.textInput.becomeFirstResponder()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCustomBackButton()
        keyboardBehavior.start()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(MainTrackingEvent.enterENSName)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardBehavior.stop()
    }

    @IBAction func didTapConfirm(_ sender: Any) {
        confirm()
    }

    private func confirm() {
        guard let address = ensAddressView.address, !address.isEmpty else { return }
        delegate?.ensInputViewControllerDidConfirm(self, address: address)
    }

    private func triggerUpdate(_ ensName: String) {
        self.inputReactionTimer?.invalidate()
        self.inputReactionTimer = nil
        self.ensInput.removeAllRules()

        guard !ensName.isEmpty else {
            showEmptyState()
            return
        }

        self.inputReactionTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] timer in
            guard timer.isValid, let `self` = self else { return }
            assert(Thread.isMainThread)

            self.showLoadingState()

            // we let the potentially long operation finish and then check if the results are still valid
            // for the current UI state.
            DispatchQueue.global().async { [weak self] in
                guard let `self` = self else { return }
                do {
                    let address = try ApplicationServiceRegistry.walletService.resolve(ensName: ensName)
                    DispatchQueue.main.async { [weak self] in
                        self?.setResolvedAddress(address, for: ensName)
                    }
                } catch {
                    DispatchQueue.main.async { [weak self] in
                        self?.setResolvedError(error, for: ensName)
                    }
                }
            }
        }
    }

    private func showEmptyState() {
        navigationItem.titleView = nil
        confirmBarButton.isEnabled = false
        ensAddressView.address = nil
    }

    private func showLoadingState() {
        // to prevent flickering, we only assign the indicator if it's not running yet
        if navigationItem.titleView == nil {
            navigationItem.titleView = LoadingTitleView()
        }
        confirmBarButton.isEnabled = false
    }

    private func setResolvedAddress(_ address: String, for ensName: String) {
        guard ensInput.text == ensName else { return }
        navigationItem.titleView = nil
        confirmBarButton.isEnabled = true
        ensAddressView.address = address
    }

    private func setResolvedError(_ error: Error, for ensName: String) {
        guard ensInput.text == ensName else { return }
        showEmptyState()
        ensInput.setExplicitError(error.localizedDescription)
    }

}


extension ENSInputViewController: VerifiableInputDelegate {

    func verifiableInputDidReturn(_ verifiableInput: VerifiableInput) {
        confirm()
    }

    func verifiableInputDidBeginEditing(_ verifiableInput: VerifiableInput) {
        keyboardBehavior.activeTextField = verifiableInput.textInput
    }

    func verifiableInputWillEnter(_ verifiableInput: VerifiableInput, newValue: String) {
        triggerUpdate(newValue)
    }

}

class ENSAddressView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var identiconView: IdenticonView!
    @IBOutlet weak var addressLabel: FullEthereumAddressLabel!

    enum Strings {
        static let title = "Address Found"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = Strings.title
        titleLabel.textColor = ColorName.darkBlue.color
        addressLabel.makeBold()
    }

    var address: String? {
        get { addressLabel.address }
        set {
            identiconView.seed = newValue ?? ""
            addressLabel.address = newValue
            isHidden = newValue == nil || newValue!.isEmpty
        }
    }

}
