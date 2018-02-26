//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

enum RuleStatus {
    case error
    case success
    case inactive
}

final class RuleLabel: UILabel {

    override func awakeFromNib() {
        super.awakeFromNib()
        font = FontName.body // TODO: 23/02/18 support dynamic type change observing
        status = .inactive
    }

    var status: RuleStatus = .inactive {
        didSet {
            stylize()
        }
    }

    private func stylize() {
        textColor = RuleLabel.color(for: status)
    }

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
