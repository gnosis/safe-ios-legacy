//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

public final class TextInput: UIView {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var stackView: UIStackView!

    private var allRules: [RuleLabel] {
        return stackView.arrangedSubviews.flatMap { $0 as? RuleLabel }
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        loadContentsFromNib()
    }

    public func addRule(_ localizedDescription: String, validation: @escaping (String) -> Bool) {
        let label = RuleLabel(text: localizedDescription, rule: validation)
        stackView.addArrangedSubview(label)
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
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

    private func resetRules() {
        allRules.forEach { $0.reset() }
    }

}
