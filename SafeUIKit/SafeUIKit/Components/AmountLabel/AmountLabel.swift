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

    public var amount: TokenData? {
        didSet {
            update()
        }
    }

    public override func commonInit() {
        update()
    }

    public override func update() {
        text = formattedText()
    }

    private func formattedText() -> String? {
        guard let amount = amount else { return nil }
        return formatter.localizedString(from: amount,
                                         forcePlusSign: isShowingPlusSign,
                                         shortFormat: isShowingShortFormat)
    }

}
