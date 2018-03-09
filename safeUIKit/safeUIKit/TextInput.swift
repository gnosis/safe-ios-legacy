//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

public protocol TextInputDelegate: class {

    func textInputDidReturn()

}

public final class TextInput: UIView {

    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var stackView: UIStackView!

    public weak var delegate: TextInputDelegate?

    private var allRules: [RuleLabel] {
        return stackView.arrangedSubviews.flatMap { $0 as? RuleLabel }
    }

    public var text: String? { return textField.text }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    public func addRule(_ localizedDescription: String, validation: ((String) -> Bool)? = nil) {
        let label = RuleLabel(text: localizedDescription, rule: validation)
        stackView.addArrangedSubview(label)
    }

    public override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        return textField.becomeFirstResponder()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    private func configure() {
        loadContentsFromNib()
        textField.delegate = self
        textField.clearButtonMode = .whileEditing
    }

    private func loadContentsFromNib() {
        let bundle = Bundle(for: TextInput.self)
        let nib = UINib(nibName: "TextInput", bundle: bundle)
        let contents = nib.instantiate(withOwner: self)
        contents.flatMap { $0 as? UIView }.forEach { self.addSubview($0) }
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
            delegate?.textInputDidReturn()
        }
        return shouldReturn
    }

    private func resetRules() {
        allRules.forEach { $0.reset() }
    }

}
