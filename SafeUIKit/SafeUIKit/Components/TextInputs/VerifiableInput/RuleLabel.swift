//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public enum RuleStatus {

    case error
    case success
    case inactive

    var localizedDescription: String {
        switch self {
        case .error: return LocalizedString("rule.error", comment: "Error status of a rule")
        case .success: return LocalizedString("rule.success", comment: "Success status of a rule")
        case .inactive: return LocalizedString("rule.inactive", comment: "Inactive status of a rule")
        }
    }

}

final class RuleLabel: UIView {

    @IBOutlet var wrapperView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!

    private var rule: ((String) -> Bool)?
    private (set) var status: RuleStatus = .inactive {
        didSet {
            update()
        }
    }

    convenience init(text: String, rule: ((String) -> Bool)? = nil) {
        self.init(frame: .zero)
        self.label.text = text
        self.rule = rule
        update()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    private func commonInit() {
        loadContentsFromNib()
        backgroundColor = .clear
        wrapperView.backgroundColor = .clear
    }

    private func loadContentsFromNib() {
        safeUIKit_loadFromNib()
        pinWrapperToSelf()
    }

    private func pinWrapperToSelf() {
        NSLayoutConstraint.activate([
            wrapperView.leadingAnchor.constraint(equalTo: leadingAnchor),
            wrapperView.trailingAnchor.constraint(equalTo: trailingAnchor),
            wrapperView.topAnchor.constraint(equalTo: topAnchor),
            wrapperView.bottomAnchor.constraint(equalTo: bottomAnchor)])
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
    }

    func validate(_ text: String) {
        guard let isValid = rule?(text) else { return }
        status = isValid ? .success : .error
    }

    func reset() {
        status = .inactive
    }

    private func update() {
        imageView.image = image(for: status)
        label.accessibilityValue = [status.localizedDescription, label.text].compactMap { $0 }.joined(separator: " ")
    }

    private func image(for status: RuleStatus) -> UIImage {
        switch status {
        case .error:
            return Asset.TextInputs.errorIcon.image
        case .inactive:
            return Asset.closeIcon.image
        case .success:
            return Asset.checkmarkSelected.image
        }
    }

}
