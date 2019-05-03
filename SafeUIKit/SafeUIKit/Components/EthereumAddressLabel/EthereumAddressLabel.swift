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

    public var hasFullAddressTooltip: Bool {
        get { return tooltipSource.isActive }
        set { tooltipSource.isActive = newValue }
    }

    private var tooltipSource: TooltipSource!

    public override func commonInit() {
        formatter.hexMode = .mixedcased
        formatter.truncationMode = .middle
        formatter.usesHeadTailSplit = true
        formatter.headLength = 2
        formatter.tailLength = 4
        tooltipSource = TooltipSource(target: self)
        tooltipSource.isActive = false
        update()
    }

    public override func update() {
        text = formattedText()
        tooltipSource.message = address
    }

    private func formattedText() -> String? {
        guard let address = address else { return nil }
        return [formatter.string(from: address), suffix].compactMap { $0 }.joined(separator: " ")
    }

}
