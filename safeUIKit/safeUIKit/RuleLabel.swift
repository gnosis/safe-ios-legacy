//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

public enum RuleStatus {
    case error
    case success
    case inactive

    var localizedDescription: String {
        switch self {
        case .error: return NSLocalizedString("rule.error", comment: "Error status of a rule")
        case .success: return NSLocalizedString("rule.success", comment: "Success status of a rule")
        case .inactive: return NSLocalizedString("rule.inactive", comment: "Inactive status of a rule")
        }
    }
}

final class RuleLabel: UILabel {

    private var rule: ((String) -> Bool)?

    convenience init(text: String, rule: ((String) -> Bool)? = nil) {
        self.init(frame: .zero)
        self.text = text
        self.rule = rule
        update()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    private func configure() {
        font = FontName.body // TODO: 23/02/18 support dynamic type change observing
        status = .inactive
    }

    private (set) var status: RuleStatus = .inactive {
        didSet {
            update()
        }
    }

    func validate(_ text: String) {
        guard let isValid = rule?(text) else { return }
        status = isValid ? .success : .error
    }

    func reset() {
        status = .inactive
    }

    private func update() {
        textColor = color(for: status)
        accessibilityValue = [status.localizedDescription, text].flatMap { $0 }.joined(separator: " ")
    }

    private func color(for status: RuleStatus) -> UIColor {
        switch status {
        case .error:
            return ColorName.red.color
        case .inactive:
            return ColorName.gray.color
        case .success:
            return ColorName.green.color
        }
    }

}
