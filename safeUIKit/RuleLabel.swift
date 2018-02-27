//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

public enum RuleStatus {
    case error
    case success
    case inactive
}

public final class RuleLabel: UILabel {

    public override func awakeFromNib() {
        super.awakeFromNib()
        font = FontName.body // TODO: 23/02/18 support dynamic type change observing
        status = .inactive
    }

    public var status: RuleStatus = .inactive {
        didSet {
            stylize()
        }
    }

    private func stylize() {
        textColor = RuleLabel.color(for: status)
    }

    public static func color(for status: RuleStatus) -> UIColor {
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
