//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

@objc public protocol TextInputDelegate: class {

    func textInputDidReturn(_ textInput: TextInput)
    @objc optional func textInputDidBeginEditing(_ textInput: TextInput)
    @objc optional func textInputDidEndEditing(_ textInput: TextInput)

}

public final class TextInput: UIView {

    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var stackView: UIStackView!

    public weak var delegate: TextInputDelegate?
    /// Indicates whether the view has user input focus
    public private(set) var isActive: Bool = false
    private static let shakeAnimationKey = "shake"

    private var allRules: [RuleLabel] {
        return stackView.arrangedSubviews.compactMap { $0 as? RuleLabel }
    }

    @IBInspectable
    public var maxLength: Int = Int.max

    public var text: String? {
        get { return textField.text }
        set { textField.text = newValue != nil ? String(newValue!.prefix(maxLength)) : nil }
    }

    public var isEnabled: Bool {
        get { return textField.isEnabled }
        set { textField.isEnabled = newValue }
    }

    public var isSecure: Bool {
        get { return textField.isSecureTextEntry }
        set { textField.isSecureTextEntry = newValue }
    }

    public var isShaking: Bool {
        return layer.animation(forKey: TextInput.shakeAnimationKey) != nil
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    public override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    private func configure() {
        loadContentsFromNib()
        textField.delegate = self
        textField.clearButtonMode = .whileEditing
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }

    private func loadContentsFromNib() {
        let bundle = Bundle(for: TextInput.self)
        let nib = UINib(nibName: "TextInput", bundle: bundle)
        let contents = nib.instantiate(withOwner: self)
        contents.compactMap { $0 as? UIView }.forEach { self.addSubview($0) }
        self.heightAnchor.constraint(equalTo: stackView.heightAnchor).isActive = true
        wrapperView.heightAnchor.constraint(equalTo: stackView.heightAnchor).isActive = true
        pinWrapperToSelf()
    }

    private func pinWrapperToSelf() {
        NSLayoutConstraint.activate([
            wrapperView.leadingAnchor.constraint(equalTo: leadingAnchor),
            wrapperView.trailingAnchor.constraint(equalTo: trailingAnchor),
            wrapperView.topAnchor.constraint(equalTo: topAnchor)])
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
    }

    public func addRule(_ localizedDescription: String, validation: ((String) -> Bool)? = nil) {
        let label = RuleLabel(text: localizedDescription, rule: validation)
        stackView.addArrangedSubview(label)
    }

    public override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        isActive = textField.becomeFirstResponder()
        return isActive
    }

    public func shake() {
        layer.add(CABasicAnimation.shake(center: center), forKey: TextInput.shakeAnimationKey)
    }

    @objc private func textChanged(_ sender: Any) {
        text = textField.text // validation
    }

}

extension TextInput: UITextFieldDelegate {

    public func textField(_ textField: UITextField,
                          shouldChangeCharactersIn range: NSRange,
                          replacementString string: String) -> Bool {
        let oldText = (textField.text ?? "") as NSString
        let newText = oldText.replacingCharacters(in: range, with: string)
        guard !newText.isEmpty else {
            resetRules()
            return true
        }
        allRules.forEach { $0.validate(newText) }
        return true
    }

    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        resetRules()
        return true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let shouldReturn = !allRules.contains { $0.status != .success }
        if shouldReturn {
            delegate?.textInputDidReturn(self)
        }
        return shouldReturn
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.textInputDidBeginEditing?(self)
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textInputDidEndEditing?(self)
    }

    private func resetRules() {
        allRules.forEach { $0.reset() }
    }

}
