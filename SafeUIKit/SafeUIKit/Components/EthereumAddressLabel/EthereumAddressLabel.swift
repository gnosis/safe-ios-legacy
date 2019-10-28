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

    public var showsBothNameAndAddress: Bool = true

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

    // This produces 3 different formats:
    //  1) name suffix
    //  2) address suffix
    //  3) name suffix \n
    //     address
    private func formattedText() -> NSAttributedString? {
        guard let address = address else { return nil }
        let suffixStr = NSAttributedString(string: suffix == nil ? "" : " \(suffix!)")
        if let name = name {
            let str = NSMutableAttributedString(string: name)
            str.append(suffixStr)

            if showsBothNameAndAddress, let addressStr = withNameFormatter.attributedString(from: address) {
                str.append(NSAttributedString(string: "\n"))
                str.append(addressStr)
            }
            return str
        } else if let addressStr = formatter.attributedString(from: address) {
            let str = NSMutableAttributedString(attributedString: addressStr)
            str.append(suffixStr)
            return str
        }
        return nil
    }

}
