//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

public class TooltipSource {

    private weak var tooltip: FeedbackTooltip?
    private weak var target: UIView?

    public var isActive: Bool = true
    public var message: String?

    public init(target: UIView) {
        self.target = target
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        target.addGestureRecognizer(tapRecognizer)
        target.isUserInteractionEnabled = true
    }

    @objc private func didTap() {
        if let tooltip = self.tooltip, tooltip.isVisible {
            tooltip.hide()
            return
        }
        guard isActive,
            let message = self.message, !message.isEmpty,
            let window = UIApplication.shared.keyWindow,
            let target = target else { return }
        tooltip = FeedbackTooltip.show(for: target, in: window, message: message)
    }

}
