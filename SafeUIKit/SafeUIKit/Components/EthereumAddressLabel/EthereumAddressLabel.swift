//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public class EthereumAddressLabel: BaseCustomLabel {

    /// used when displaying address with or without suffix
    public private(set) var formatter = EthereumAddressFormatter()

    /// used when displaying address with name
    lazy var withNameFormatter: EthereumAddressFormatter = {
        let formatter = EthereumAddressFormatter()
        formatter.hexMode = .mixedcased
        formatter.truncationMode = .middle
        formatter.usesHeadTailSplit = true
        formatter.headLength = 2
        formatter.tailLength = 4
        formatter.bodyAttributes = [.foregroundColor: ColorName.mediumGrey.color]
        formatter.headAttributes = formatter.bodyAttributes
        formatter.tailAttributes = formatter.bodyAttributes
        return formatter
    }()

    public var address: String? {
        didSet {
            update()
        }
    }

    public var name: String? {
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

    var tooltipSource: TooltipSource!

    public override func commonInit() {
        formatter.hexMode = .mixedcased
        formatter.truncationMode = .middle
        formatter.usesHeadTailSplit = true
        formatter.headLength = 2
        formatter.tailLength = 4
        tooltipSource = TooltipSource(target: self)
        tooltipSource.isActive = false
        numberOfLines = 0
        update()
    }

    public override func update() {
        attributedText = formattedText()
        tooltipSource.message = address
    }

    private func formattedText() -> NSAttributedString? {
        guard let address = address else { return nil }
        if let suffix = suffix {
            let str = NSMutableAttributedString()
            if let addressStr = formatter.attributedString(from: address) {
                str.append(addressStr)
            }
            str.append(NSAttributedString(string: " \(suffix)"))
            return str
        } else if let name = name {
            let str = NSMutableAttributedString(string: name + "\n")
            if let addressStr = withNameFormatter.attributedString(from: address) {
                str.append(addressStr)
            }
            return str
        } else {
            return formatter.attributedString(from: address)
        }
    }

}
