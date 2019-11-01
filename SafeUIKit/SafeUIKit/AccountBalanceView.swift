//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import Common

public class AccountBalanceView: BaseCustomView {

    private var identiconView = IdenticonView()
    private var addressLabel = EthereumAddressLabel()
    private var balanceLabel = AmountLabel()

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

    public var amount: TokenData? {
        didSet {
            update()
        }
    }

    public override func commonInit() {
        let stackView = UIStackView(arrangedSubviews: [identiconView, addressLabel, balanceLabel])
        ([stackView] + stackView.arrangedSubviews).forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        addSubview(stackView)
        NSLayoutConstraint.activate([
            identiconView.widthAnchor.constraint(equalToConstant: 32),
            identiconView.heightAnchor.constraint(equalToConstant: 32),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            heightAnchor.constraint(equalTo: stackView.heightAnchor)])
        stackView.alignment = .center
        stackView.spacing = 14
        addressLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        addressLabel.textColor = ColorName.darkBlue.color
        addressLabel.hasFullAddressTooltip = true
        balanceLabel.font = UIFont.systemFont(ofSize: 17)
        balanceLabel.textColor = ColorName.darkBlue.color
        balanceLabel.textAlignment = .right
        balanceLabel.isShowingPlusSign = false
        balanceLabel.hasTooltip = true
        backgroundColor = ColorName.snowwhite.color
        update()
    }

    public override func update() {
        identiconView.seed = address ?? ""
        addressLabel.address = address
        addressLabel.name = name
        balanceLabel.amount = amount
    }

}
