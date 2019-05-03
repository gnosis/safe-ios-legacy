//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

@objc public protocol VerifiableInputDelegate: class {
    func verifiableInputDidReturn(_ verifiableInput: VerifiableInput)
    @objc optional func verifiableInputDidBeginEditing(_ verifiableInput: VerifiableInput)
    @objc optional func verifiableInputDidEndEditing(_ verifiableInput: VerifiableInput)
    @objc optional func verifiableInputWillEnter(_ verifiableInput: VerifiableInput, newValue: String)
}

open class VerifiableInput: UIView {

    @IBOutlet var wrapperView: UIView!
    @IBOutlet public private(set) weak var textInput: TextInput!
    @IBOutlet weak var stackView: UIStackView!

    /// Indicates whether the view has user input focus
    public private(set) var isActive: Bool = false

    public weak var delegate: VerifiableInputDelegate?

    private static let shakeAnimationKey = "shake"
    private let spacingViewHeight: CGFloat = 4

    private var allRules: [RuleLabel] {
        return stackView.arrangedSubviews.compactMap { $0 as? RuleLabel }
    }

    public var isValid: Bool {
        return allRules.reduce(true) { $0 && $1.status == .success }
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

    public var maxLength: Int = Int.max

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
        backgroundColor = .clear
        wrapperView.backgroundColor = .clear
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

    public func addRule(_ localizedDescription: String,
                        identifier: String? = nil,
                        displayIcon: Bool = false,
                        validation: ((String) -> Bool)? = nil) {
        addSpacingIfNeeded()
        let ruleLabel = RuleLabel(text: localizedDescription, displayIcon: displayIcon, rule: validation)
        ruleLabel.accessibilityIdentifier = identifier
        hideRuleIfNeeded(ruleLabel)
        stackView.addArrangedSubview(ruleLabel)
    }

    private func addSpacingIfNeeded() {
        guard allRules.isEmpty else { return }
        let spacingView = UIView()
        spacingView.addConstraint(spacingView.heightAnchor.constraint(equalToConstant: spacingViewHeight))
        stackView.addArrangedSubview(spacingView)
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

    func validateRules(for text: String) {
        guard !text.isEmpty else {
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

    @discardableResult
    public func verify() -> Bool {
        if isValid {
            delegate?.verifiableInputDidReturn(self)
        } else {
            shake()
        }
        return isValid
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

    private func resetRules() {
        allRules.forEach {
            $0.reset()
            hideRuleIfNeeded($0)
        }
        textInput.inputState = .normal
    }

    private func hideRuleIfNeeded(_ rule: RuleLabel) {
        guard let text = rule.text, !text.isEmpty else {
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

}
