//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

public enum RuleStatus {
    case error
    case success
    case inactive
}

final class RuleLabel: UILabel {

    private var rule: ((String) -> Bool)?

    convenience init(text: String, rule: ((String) -> Bool)? = nil) {
        self.init(frame: .zero)
        self.text = text
        self.rule = rule
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
            stylize()
        }
    }

    func validate(_ text: String) {
        guard let isValid = rule?(text) else { return }
        status = isValid ? .success : .error
    }

    private func stylize() {
        textColor = RuleLabel.color(for: status)
    }

    // TODO: make private
    static func color(for status: RuleStatus) -> UIColor {
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
