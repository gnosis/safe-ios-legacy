//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import Common

extension BasicTableViewCell {

    static var tokenDataCellHeight: CGFloat {
        return 62
    }

    static var tokenDataWithNameCellHeight: CGFloat {
        return 70
    }

    func configure(tokenData: TokenData,
                   displayBalance: Bool,
                   displayFullName: Bool,
                   roundUp: Bool = false,
                   accessoryType: AccessoryType = .disclosureIndicator) {
        accessibilityIdentifier = tokenData.name
        self.accessoryType = accessoryType
        if tokenData.code == "ETH" {
            leftImageView.image = Asset.TokenIcons.eth.image
        } else if let url = tokenData.logoURL {
            leftImageView.kf.setImage(with: url, placeholder: Asset.TokenIcons.defaultToken.image)
        } else {
            leftImageView.image = Asset.TokenIcons.defaultToken.image
        }
        if displayFullName {
            let tokenFullName = NSMutableAttributedString()
            let tokenCode = NSAttributedString(string: tokenData.code + "\n", style: TokenCodeStyle())
            let tokenName = NSAttributedString(string: tokenData.name, style: TokenNameStyle())
            tokenFullName.append(tokenCode)
            tokenFullName.append(tokenName)
            leftTextLabel.numberOfLines = 0
            leftTextLabel.attributedText = tokenFullName
        } else {
            leftTextLabel.text = tokenData.code
        }
        rightTextLabel.text = displayBalance ? formattedBalance(tokenData, roundUp: roundUp) : nil
    }

    private func formattedBalance(_ tokenData: TokenData, roundUp: Bool) -> String {
        guard let decimal = tokenData.decimalAmount else { return "--" }
        let formatter = TokenFormatter()
        formatter.roundingBehavior = roundUp ? .roundUp : .cutoff
        return formatter.string(from: decimal)
    }

}

fileprivate class TokenCodeStyle: AttributedStringStyle {

    override var fontSize: Double { return 16 }
    override var fontWeight: UIFont.Weight { return .medium }
    override var fontColor: UIColor { return ColorName.darkSlateBlue.color }
    override var spacingAfterParagraph: Double { return 4 }

}

fileprivate class TokenNameStyle: AttributedStringStyle {

    override var fontSize: Double { return 13 }
    override var fontWeight: UIFont.Weight { return .medium }
    override var fontColor: UIColor { return ColorName.battleshipGrey.color }

}
