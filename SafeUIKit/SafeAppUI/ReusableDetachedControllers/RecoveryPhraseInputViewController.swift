//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import Common
import SafeUIKit

protocol RecoveryPhraseInputViewControllerDelegate: class {

    func recoveryPhraseInputViewControllerDidFinish()
    func recoveryPhraseInputViewController(_ controller: RecoveryPhraseInputViewController,
                                           didEnterPhrase phrase: String)
}

class RecoveryPhraseInputViewController: BaseInputViewController {

    @IBOutlet weak var phraseTextView: CustomTextView!
    var keyboardBehavior: KeyboardAvoidingBehavior!
    weak var delegate: RecoveryPhraseInputViewControllerDelegate?
    var backButtonItem: UIBarButtonItem!
    private var didCancel = false

    override var headerText: String {
        return LocalizedString("enter_seed", comment: "Recovery Phrase Input screen header")
    }

    override var actionFailureMessageFormat: String {
        return LocalizedString("ios_incorrect_seed_error_format", comment: "Error format for invalid recovery phrase")
    }

    static let maxInputLength: Int = 500
    var placeholder: String = LocalizedString("enter_recovery", comment: "Placeholder for the recovery phrase")

    var screenTrackingEvent: Trackable?
    var text: String? {
        didSet {
            update()
        }
    }

    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var placeholderTop: NSLayoutConstraint!
    @IBOutlet weak var placeholderTrailing: NSLayoutConstraint!
    @IBOutlet weak var placeholderLeading: NSLayoutConstraint!

    static func create(delegate: RecoveryPhraseInputViewControllerDelegate?) -> RecoveryPhraseInputViewController {
        let controller = StoryboardScene.RecoverSafe.recoveryPhraseInputViewController.instantiate()
        controller.delegate = delegate
        return controller
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backButtonItem = UIBarButtonItem.backButton(target: self, action: #selector(back))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.isWhite = true
        keyboardBehavior = KeyboardAvoidingBehavior(scrollView: scrollView)

        phraseTextView.layer.cornerRadius = 10
        phraseTextView.layer.borderColor = ColorName.whitesmoke.color.cgColor
        phraseTextView.layer.borderWidth = 2
        phraseTextView.textColor = ColorName.darkBlue.color
        phraseTextView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        phraseTextView.font = UIFont.systemFont(ofSize: 16, weight: .regular)

        let insets = textInsets()
        placeholderTop.constant = insets.top
        placeholderLeading.constant = insets.left
        placeholderTrailing.constant = -insets.right
        placeholderLabel.textColor = ColorName.darkBlue50.color

        view.setNeedsUpdateConstraints()
        update()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let event = screenTrackingEvent {
            trackEvent(event)
        }
    }

    override func willMove(toParent parent: UIViewController?) {
        setCustomBackButton(backButtonItem)
    }

    private func textInsets() -> UIEdgeInsets {
        var insets = phraseTextView.textContainerInset
        insets.left += phraseTextView.textContainer.lineFragmentPadding
        insets.right += phraseTextView.textContainer.lineFragmentPadding
        switch Locale.lineDirection(forLanguage: Locale.autoupdatingCurrent.languageCode ?? "en_US") {
        case .leftToRight, .topToBottom, .unknown:
            return insets
        case .rightToLeft:
            let tmp = insets.left
            insets.left = insets.right
            insets.right = tmp
            return insets
        case .bottomToTop:
            let tmp = insets.bottom
            insets.bottom = insets.top
            insets.top = tmp
            return insets
        @unknown default:
            return insets
        }
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardBehavior.start()
        didCancel = false
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardBehavior.stop()
    }

    @objc func back() {
        didCancel = true
    }

    func update() {
        guard isViewLoaded else { return }
        phraseTextView.text = text
        updateTextDependentViews(with: text)
    }

    func updateTextDependentViews(with rawText: String?) {
        let text = (rawText ?? "")
        placeholderLabel.isHidden = !text.isEmpty
        nextButtonItem.isEnabled = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    override func next(_ sender: Any) {
        disableNextAction()
        startActivityIndicator()
        let phrase = safeUserInputText()
        delegate?.recoveryPhraseInputViewController(self, didEnterPhrase: phrase)
    }

    public func handleSuccess() {
        guard !didCancel else { return }
        DispatchQueue.main.async {
            self.stopActivityIndicator()
            self.enableNextAction()
            self.delegate?.recoveryPhraseInputViewControllerDidFinish()
        }
    }

    public func handleError(_ error: Error) {
        guard !didCancel else { return }
        DispatchQueue.main.async {
            self.stopActivityIndicator()
            self.enableNextAction()
            self.show(error: error)
        }
    }

    private func safeUserInputText() -> String {
        return String((phraseTextView.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .prefix(RecoveryPhraseInputViewController.maxInputLength))
    }

    override func notify() {
        DispatchQueue.main.async {
            self.handleSuccess()
        }
    }

}

extension RecoveryPhraseInputViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        keyboardBehavior.activeTextView = textView
    }

    func textViewDidChange(_ textView: UITextView) {
        updateTextDependentViews(with: textView.text)
    }

}


class CustomTextView: UITextView {

    override func caretRect(for position: UITextPosition) -> CGRect {
        var rect = super.caretRect(for: position)
        rect.size.width = min(1, rect.width)
        rect.size.height = max((font?.lineHeight ?? 21) + 2, rect.height)
        return rect
    }

}
