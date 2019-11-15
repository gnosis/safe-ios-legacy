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
        case .error: return "error"
        case .success: return "success"
        case .inactive: return "inactive"
        }
    }

}

final class RuleLabel: UIView {

    @IBOutlet var wrapperView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!

    var currentText: String? {
        return label.text
    }

    private var errorText: String?
    private var successText: String?
    private var inactiveText: String?

    private var rule: ((String) -> Bool)?
    private (set) var status: RuleStatus = .inactive {
        didSet {
            update()
        }
    }

    convenience init(text: String,
                     successText: String? = nil,
                     inactiveText: String? = nil,
                     displayIcon: Bool = false,
                     rule: ((String) -> Bool)? = nil) {
        self.init(frame: .zero)
        if !displayIcon {
            imageView.removeFromSuperview()
            imageView = nil
        }
        self.rule = rule
        self.errorText = text
        self.successText = successText
        self.inactiveText = inactiveText
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
        backgroundColor = ColorName.transparent.color
        wrapperView.backgroundColor = ColorName.transparent.color
        label.textColor = ColorName.darkGrey.color
    }

    private func loadContentsFromNib() {
        safeUIKit_loadFromNib(forClass: RuleLabel.self)
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
        _ = rule?("") // updating rule to give chance to react rule's clients to reset() call
        status = .inactive
    }

    private func update() {
        updateImage()
        updateLabel()
        updateText()
    }

    private func updateImage() {
        guard imageView != nil else { return }
        switch status {
        case .error:
            imageView.image = Asset.errorIcon.image
        case .inactive:
            imageView.image = Asset.defaultIcon.image
        case .success:
            imageView.image = Asset.successIcon.image
        }
    }

    private func updateLabel() {
        label.accessibilityValue = [status.localizedDescription, label.text].compactMap { $0 }.joined(separator: " ")
        guard imageView == nil else { return }
        switch status {
        case .error:
            label.textColor = ColorName.tomato.color
        case .inactive:
            label.textColor = ColorName.darkGrey.color
        case .success:
            label.textColor = ColorName.hold.color
        }
    }

    private func updateText() {
        switch status {
        case .error:
            label.text = errorText
        case .inactive:
            label.text = inactiveText ?? errorText
        case .success:
            label.text = successText ?? errorText
        }
    }

}
