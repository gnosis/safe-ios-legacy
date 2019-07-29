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

    private let defaultBodyAttributes: [NSAttributedString.Key: Any] =
        [.foregroundColor: ColorName.mediumGrey.color]
    private let selectedBodyAttributes: [NSAttributedString.Key: Any] =
        [.foregroundColor: ColorName.mediumGrey.color,
         .backgroundColor: ColorName.systemBlue.color]

    public override func commonInit() {
        formatter.hexMode = .mixedcased
        formatter.truncationMode = .off
        formatter.headLength = 2
        formatter.tailLength = 4
        formatter.bodyAttributes = defaultBodyAttributes
        formatter.headAttributes = [.foregroundColor: ColorName.black.color]
        formatter.tailAttributes = formatter.headAttributes
        // swiftlint:disable:next multiline_arguments
        tooltipSource = TooltipSource(target: self, onTap: { [weak self] in
            guard let `self` = self else { return }
            UIPasteboard.general.string = self.address
        }, onAppear: { [weak self] in
            self?.tooltipWillShow()
        }, onDisappear: { [weak self] in
            self?.tooltipWillHide()
        })
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

    func tooltipWillShow() {
        formatter.bodyAttributes = selectedBodyAttributes
        attributedText = formattedText()
    }

    func tooltipWillHide() {
        formatter.bodyAttributes = defaultBodyAttributes
        attributedText = formattedText()
    }

}
