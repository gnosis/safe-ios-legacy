//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

@objc public protocol VerifiableInputDelegate: class {

    /// Called when the verification passess all rules successfully.
    /// This happens either on pressing Enter in the field, or by calling `verify()` method.
    /// - Parameter verifiableInput: input on which the verification was called.
    func verifiableInputDidReturn(_ verifiableInput: VerifiableInput)

    /// Called when the text field begins editing.
    /// - Parameter verifiableInput: input in which editing starts
    @objc optional func verifiableInputDidBeginEditing(_ verifiableInput: VerifiableInput)

    /// Called when text field ends editing
    /// - Parameter verifiableInput: input in which editing stops
    @objc optional func verifiableInputDidEndEditing(_ verifiableInput: VerifiableInput)

    /// Called when input is about to replace current text with a new text.
    /// - Parameter verifiableInput: input in which entry occurs
    /// - Parameter newValue: new text to replace current one.
    @objc optional func verifiableInputWillEnter(_ verifiableInput: VerifiableInput, newValue: String)

}

open class VerifiableInput: UIView {

    @IBOutlet var wrapperView: UIView!
    @IBOutlet public private(set) weak var textInput: TextInput!
    @IBOutlet weak var stackView: UIStackView!
    private var spacingConstraint: NSLayoutConstraint!
    private var spacingView: UIView!
    private weak var lastAddedRule: RuleLabel?

    /// Indicates whether the view has user input focus
    public private(set) var isActive: Bool = false

    public weak var delegate: VerifiableInputDelegate?

    private static let shakeAnimationKey = "shake"

    private var allRules: [RuleLabel] {
        return stackView.arrangedSubviews.compactMap { $0 as? RuleLabel }
    }

    public var isValid: Bool {
        return allRules.allSatisfy { $0.status == .success }
    }

    public var trimsText: Bool = false {
        didSet {
            revalidateText()
        }
    }

    // Makes rule text invisible by default. Rules appear only when they error. If true, then
    // `adjustsHeightForHiddenRules` is applied.
    public var showErrorsOnly: Bool = false

    // If true, the height of input is always the same as if all rules are shown. This is applied only when
    // `showsErrorOnly` is true.
    public var adjustsHeightForHiddenRules: Bool = false

    /// Adds additional spacing after the text input.
    public var spacingAfterInput: CGFloat = 4 {
        didSet {
            updateSpacingView()
        }
    }

    public var maxLength: Int = Int.max

    public var validateEmptyText = false

    /// When setting this property textInput.text value is formatted and validated.
    public var text: String? {
        get {
            return textInput.text
        }
        set {
            textInput.text = newValue != nil ? safeUserInput(newValue!) : nil
            validateRules(for: newValue ?? "")
        }
    }
    public var rigthView: UIView? {
        didSet {
            textInput.customRightView = rigthView
        }
    }

    public func revalidateText() {
        let str = text
        text = str
    }

    internal func safeUserInput(_ text: String?) -> String {
        var result = String(text!.prefix(maxLength))
        if trimsText {
            result = result.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return result
    }

    public var isEnabled: Bool {
        get { return textInput.isEnabled }
        set { textInput.isEnabled = newValue }
    }

    public var isSecure: Bool {
        get { return textInput.isSecureTextEntry }
        set { textInput.isSecureTextEntry = newValue }
    }

    public var returnKeyType: UIReturnKeyType {
        get { return textInput.returnKeyType }
        set { textInput.returnKeyType = newValue }
    }

    public var style: TextInput.Style {
        get { return textInput.style }
        set { textInput.style = newValue }
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    private func commonInit() {
        loadContentsFromNib()
        backgroundColor = ColorName.transparent.color
        wrapperView.backgroundColor = ColorName.transparent.color
        textInput.delegate = self
        textInput.addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }

    private func loadContentsFromNib() {
        safeUIKit_loadFromNib(forClass: VerifiableInput.self)
        self.heightAnchor.constraint(equalTo: stackView.heightAnchor).isActive = true
        wrapperView.heightAnchor.constraint(equalTo: stackView.heightAnchor).isActive = true
        pinWrapperToSelf()
    }

    private func pinWrapperToSelf() {
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            wrapperView.leadingAnchor.constraint(equalTo: leadingAnchor),
            wrapperView.trailingAnchor.constraint(equalTo: trailingAnchor),
            wrapperView.topAnchor.constraint(equalTo: topAnchor)])
    }

    public func addRule(_ errorText: String,
                        successText: String? = nil,
                        inactiveText: String? = nil,
                        identifier: String? = nil,
                        displayIcon: Bool = false,
                        validation: ((String) -> Bool)? = nil) {
        addSpacingIfNeeded()
        let ruleLabel = RuleLabel(text: errorText,
                                  successText: successText,
                                  inactiveText: inactiveText,
                                  displayIcon: displayIcon,
                                  rule: validation)
        ruleLabel.accessibilityIdentifier = identifier
        hideRuleIfNeeded(ruleLabel)
        stackView.addArrangedSubview(ruleLabel)
        lastAddedRule = ruleLabel
    }

    private func removeRule(_ rule: RuleLabel) {
        rule.removeFromSuperview()
    }

    public func removeAllRules() {
        allRules.forEach { $0.removeFromSuperview() }
        spacingView?.removeFromSuperview()
    }

    private func addSpacingIfNeeded() {
        guard allRules.isEmpty else { return }
        spacingView = UIView()
        spacingConstraint = spacingView.heightAnchor.constraint(equalToConstant: spacingAfterInput)
        spacingConstraint.isActive = true
        stackView.addArrangedSubview(spacingView)
    }

    private func updateSpacingView() {
        spacingConstraint?.constant = spacingAfterInput
        spacingView.isHidden = spacingAfterInput == 0
        setNeedsUpdateConstraints()
    }

    open override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        isActive = textInput.becomeFirstResponder()
        return isActive
    }

    open func shake() {
        layer.add(CABasicAnimation.shake(center: center), forKey: VerifiableInput.shakeAnimationKey)
    }

    @objc private func textChanged(_ sender: Any) {
        text = textInput.text // validation
    }

    // triggered on every text change
    func validateRules(for text: String) {
        guard !text.isEmpty || validateEmptyText else {
            resetRules()
            return
        }
        allRules.forEach {
            $0.validate(text)
            hideRuleIfNeeded($0)
        }
        let successOrNormal: TextInput.TextInputState = allRules.isEmpty ? .normal : .success
        textInput.inputState = isValid ? successOrNormal : .error
    }

    private func resetRules() {
        allRules.forEach {
            $0.reset()
            hideRuleIfNeeded($0)
        }
        textInput.inputState = .normal
    }

    private func hideRuleIfNeeded(_ rule: RuleLabel) {
        guard let text = rule.currentText, !text.isEmpty else {
            rule.isHidden = true
            return
        }
        let isError = rule.status == .error
        if showErrorsOnly {
            if adjustsHeightForHiddenRules {
                rule.alpha = isError ? 1 : 0
            } else {
                rule.isHidden = !isError
            }
        } else {
            rule.isHidden = false
        }
    }

    @discardableResult
    public func verify() -> Bool {
        if isValid {
            delegate?.verifiableInputDidReturn(self)
        } else {
            shake()
        }
        return isValid
    }

    private var explicitErrorRule: RuleLabel?
    private var explicitErrorRuleWasReset: Bool = false

    /// Shows the error immediately until the text is changed or revalidated.
    public func setExplicitError(_ error: String) {
        if let rule = explicitErrorRule {
            removeRule(rule)
        }
        self.explicitErrorRuleWasReset = false
        addRule(error) { [unowned self] _ in
            let oldValue = self.explicitErrorRuleWasReset
            if !self.explicitErrorRuleWasReset {
                self.explicitErrorRuleWasReset = true
            }
            return oldValue
        }
        explicitErrorRule = lastAddedRule
        revalidateText()
    }

}

extension VerifiableInput: UITextFieldDelegate {

    public func textField(_ textField: UITextField,
                          shouldChangeCharactersIn range: NSRange,
                          replacementString string: String) -> Bool {
        let updatedText = (textField.nonNilText as NSString).replacingCharacters(in: range, with: string)
        delegate?.verifiableInputWillEnter?(self, newValue: updatedText)
        return true
    }

    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        resetRules()
        return true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return verify()
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.verifiableInputDidBeginEditing?(self)
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.verifiableInputDidEndEditing?(self)
    }

}
