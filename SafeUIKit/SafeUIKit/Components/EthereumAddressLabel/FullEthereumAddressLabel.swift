//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public class FullEthereumAddressLabel: BaseCustomLabel {

    private enum Strings {
        static let copiedMessage = LocalizedString("copied_to_clipboard", comment: "Copied to clipboard")
    }

    public var formatter = EthereumAddressFormatter()

    public var address: String? {
        didSet {
            update()
        }
    }

    public var hasCopyAddressTooltip: Bool {
        get { return tooltipSource.isActive }
        set { tooltipSource.isActive = newValue }
    }

    private var tooltipSource: TooltipSource!

    public override func commonInit() {
        formatter.hexMode = .mixedcased
        formatter.truncationMode = .off
        formatter.headLength = 2
        formatter.tailLength = 4
        formatter.bodyAttributes = [.foregroundColor: ColorName.lightGreyBlue.color]
        formatter.headAttributes = [.foregroundColor: UIColor.black]
        formatter.tailAttributes = formatter.headAttributes
        tooltipSource = TooltipSource(target: self) { [unowned self] in
            UIPasteboard.general.string = self.address
        }
        tooltipSource.isActive = false
        numberOfLines = 0
        lineBreakMode = .byCharWrapping
        minimumScaleFactor = 0.7
        update()
    }

    public override func update() {
        attributedText = formattedText()
        tooltipSource.message = Strings.copiedMessage
    }

    private func formattedText() -> NSAttributedString? {
        guard let address = address else { return nil }
        return formatter.attributedString(from: address)
    }

}
