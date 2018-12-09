//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public class FullEthereumAddressLabel: BaseCustomLabel {

    public var formatter = EthereumAddressFormatter()

    public var address: String? {
        didSet {
            update()
        }
    }

    public override func commonInit() {
        formatter.hexMode = .mixedcased
        formatter.truncationMode = .off
        formatter.headLength = 2
        formatter.tailLength = 4
        formatter.bodyAttributes = [.foregroundColor: ColorName.blueyGrey.color]
        formatter.headAttributes = [.foregroundColor: UIColor.black]
        formatter.tailAttributes = formatter.headAttributes
        numberOfLines = 0
        lineBreakMode = .byCharWrapping
        update()
    }

    public override func update() {
        attributedText = formattedText()
    }

    private func formattedText() -> NSAttributedString? {
        guard let address = address else { return nil }
        return formatter.attributedString(from: address)
    }

}
