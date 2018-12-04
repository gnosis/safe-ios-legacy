//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import Common
import Kingfisher

public final class TokenBalanceTableViewCell: UITableViewCell {

    @IBOutlet public private(set) weak var tokenImageView: UIImageView!
    @IBOutlet public private(set) weak var tokenCodeLabel: UILabel!
    @IBOutlet public private(set) weak var tokenBalanceLabel: UILabel!
    @IBOutlet public private(set) weak var tokenBalanceCodeLabel: UILabel!

    public static let height: CGFloat = 60

    public enum TokenDisplayName {
        case codeOnly
        case nameOnly
        case full
    }

    private(set) var tokenData: TokenData!

    public var displayBalance: Bool = true {
        didSet {
            tokenBalanceLabel.text = displayBalance ? formattedBalance(tokenData) : nil
            tokenBalanceCodeLabel.text = displayBalance ? tokenData.code : nil
        }
    }

    public var displayName: TokenDisplayName = .codeOnly {
        didSet {
            switch displayName {
            case .codeOnly:
                tokenCodeLabel.text = tokenData.code
            case .nameOnly:
                tokenCodeLabel.text = tokenData.name
            case .full:
                tokenCodeLabel.text = "\(tokenData.code) (\(tokenData.name))"
            }
        }
    }

    public var withDisclosure: Bool = false {
        didSet {
            accessoryType = withDisclosure ? .disclosureIndicator : .none
        }
    }

    public var withTrailingSpace: Bool = false {
        didSet {
            backgroundColor = withTrailingSpace ? .clear : .white
        }
    }

    public func configure(tokenData: TokenData) {
        self.tokenData = tokenData
        accessibilityIdentifier = tokenData.name
        if tokenData.code == "ETH" {
            tokenImageView.image = Asset.TokenIcons.eth.image
        } else if let url = tokenData.logoURL {
            tokenImageView.kf.setImage(with: url, placeholder: Asset.TokenIcons.defaultToken.image)
        } else {
            tokenImageView.image = Asset.TokenIcons.defaultToken.image
        }
        displayName = .codeOnly
        displayBalance = true
    }

    private func formattedBalance(_ tokenData: TokenData) -> String {
        guard let balance = tokenData.balance else { return "--" }
        let formatter = TokenNumberFormatter.ERC20Token(decimals: tokenData.decimals)
        formatter.displayedDecimals = 8
        return formatter.string(from: balance)
    }

}
