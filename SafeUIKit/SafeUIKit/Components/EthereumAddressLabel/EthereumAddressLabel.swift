//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public class EthereumAddressLabel: BaseCustomLabel {

    public var formatter = EthereumAddressFormatter()

    public var address: String? {
        didSet {
            update()
        }
    }

    public var suffix: String? {
        didSet {
            update()
        }
    }

    public override func commonInit() {
        formatter.hexMode = .mixedcased
        formatter.truncationMode = .middle
        formatter.usesHeadTailSplit = true
        formatter.headLength = 2
        formatter.tailLength = 4
        update()
    }

    public override func update() {
        text = formattedText()
    }

    private func formattedText() -> String? {
        guard let address = address else { return nil }
        return [formatter.string(from: address), suffix].compactMap { $0 }.joined(separator: " ")
    }

}
