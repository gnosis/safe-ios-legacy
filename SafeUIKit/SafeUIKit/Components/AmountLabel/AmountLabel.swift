//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import Common

public class AmountLabel: BaseCustomLabel {

    public var formatter = TokenFormatter()

    public var isShowingPlusSign: Bool = true {
        didSet {
            update()
        }
    }

    public var isShowingShortFormat: Bool = true {
        didSet {
            update()
        }
    }

    public var hasTooltip: Bool = false {
        didSet {
            update()
        }
    }

    public var amount: TokenData? {
        didSet {
            update()
        }
    }

    private var tooltip: TooltipSource!

    public override func commonInit() {
        tooltip = TooltipSource(target: self)
        update()
    }

    public override func update() {
        text = formattedText()
        tooltip.message = formattedTooltip()
        tooltip.isActive = hasTooltip
    }

    private func formattedText() -> String? {
        guard let amount = amount else { return nil }
        return formatter.localizedString(from: amount,
                                         forcePlusSign: isShowingPlusSign,
                                         shortFormat: isShowingShortFormat)
    }

    private func formattedTooltip() -> String? {
        guard let amount = amount, hasTooltip && isShowingShortFormat else { return nil }
        return formatter.localizedString(from: amount,
                                         forcePlusSign: isShowingPlusSign,
                                         shortFormat: false)
    }

}
