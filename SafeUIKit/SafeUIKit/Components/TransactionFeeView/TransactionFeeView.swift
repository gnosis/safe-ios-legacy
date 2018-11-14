//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import Common

public class TransactionFeeView: UIView {

    enum Strings {
        static let currentBalance = LocalizedString("transaction_fee.current_balance", comment: "Current balance")
        static let transactionFee = LocalizedString("transaction_fee.transaction_fee", comment: "Transaction fee")
        static let resultingBalance = LocalizedString("transaction_fee.balance_after_transfer",
                                                      comment: "Balance after transfer")
        static let ether = LocalizedString("transaction_fee.ether", comment: "Displayed in parentheses")
        static let token = LocalizedString("transaction_fee.token", comment: "Displayed in parentheses")
    }

    private let wrapperStackView = UIStackView()
    private let displayedDecimals = 5

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    private func commonInit() {
        backgroundColor = ColorName.paleGreyThree.color
        pinWrapperStackView()
    }

    private func pinWrapperStackView() {
        wrapperStackView.axis = .vertical
        wrapperStackView.spacing = 4
        wrapperStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(wrapperStackView)
        NSLayoutConstraint.activate([
            wrapperStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            wrapperStackView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            wrapperStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            wrapperStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)])
    }

    public func configure(currentBalance: TokenData?, transactionFee: TokenData?, resultingBalance: TokenData!) {
        guard wrapperStackView.arrangedSubviews.isEmpty else { return }
        if let currentBalance = currentBalance {
            let currentBalanceStackView =
                balanceStackView(text: currentBalanceLabel(currentBalance),
                                 balance: balanceLabel(currentBalance,
                                                       bold: true,
                                                       displayedDecimals: displayedDecimals))
            wrapperStackView.addArrangedSubview(currentBalanceStackView)
        }
        let isSecondaryView = currentBalance == nil
        if let transactionFee = transactionFee {
            let transactionFeeStackView =
                balanceStackView(text: transactionFeeLabel(transactionFee,
                                                           shouldDisplayEtherText: isSecondaryView),
                                 balance: balanceLabel(transactionFee,
                                                       bold: false,
                                                       displayedDecimals: displayedDecimals))
            wrapperStackView.addArrangedSubview(transactionFeeStackView)
            if !isSecondaryView {
                let emptyView = UIView()
                emptyView.translatesAutoresizingMaskIntoConstraints = false
                emptyView.heightAnchor.constraint(equalToConstant: 6).isActive = true
                wrapperStackView.addArrangedSubview(emptyView)
            }
        } else if !isSecondaryView {
            wrapperStackView.spacing = 8
        }
        let balanceAfterTransferStackView =
            balanceStackView(text: resultingBalanceLabel(resultingBalance, bold: !isSecondaryView),
                             balance: balanceLabel(resultingBalance,
                                                   bold: !isSecondaryView,
                                                   displayedDecimals: displayedDecimals))
        wrapperStackView.addArrangedSubview(balanceAfterTransferStackView)
    }

    private func balanceStackView(text: UILabel, balance: UILabel) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.addArrangedSubview(text)
        stackView.addArrangedSubview(balance)
        return stackView
    }

    private func currentBalanceLabel(_ tokenData: TokenData) -> UILabel {
        let currentBalanceLabel = UILabel()
        currentBalanceLabel.font = UIFont.boldSystemFont(ofSize: 16)
        currentBalanceLabel.text = Strings.currentBalance
        currentBalanceLabel.textColor = ColorName.battleshipGrey.color
        if !tokenData.isEther {
            currentBalanceLabel.text! += " (\(Strings.token))"
        }
        return currentBalanceLabel
    }

    private func balanceLabel(_ tokenData: TokenData, bold: Bool, displayedDecimals: Int? = nil) -> UILabel {
        let balanceLabel = UILabel()
        balanceLabel.textAlignment = .right
        balanceLabel.font = bold ? UIFont.boldSystemFont(ofSize: 16) : UIFont.systemFont(ofSize: 16)
        balanceLabel.textColor = ColorName.battleshipGrey.color
        let formatter = TokenNumberFormatter.ERC20Token(code: tokenData.code,
                                                        decimals: tokenData.decimals,
                                                        displayedDecimals: displayedDecimals)
        balanceLabel.text = formatter.string(from: tokenData.balance ?? 0)
        balanceLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1_000), for: .horizontal)
        return balanceLabel
    }

    private func transactionFeeLabel(_ tokenData: TokenData, shouldDisplayEtherText: Bool) -> UILabel {
        let transactionFeeLabel = UILabel()
        transactionFeeLabel.font = UIFont.systemFont(ofSize: 16)
        transactionFeeLabel.text = Strings.transactionFee
        transactionFeeLabel.textColor = ColorName.battleshipGrey.color
        if shouldDisplayEtherText {
            transactionFeeLabel.text! += " (\(Strings.ether))"
        }
        return transactionFeeLabel
    }

    private func resultingBalanceLabel(_ tokenData: TokenData, bold: Bool) -> UILabel {
        let resultingBalanceLabel = UILabel()
        resultingBalanceLabel.font = bold ? UIFont.boldSystemFont(ofSize: 16) : UIFont.systemFont(ofSize: 16)
        resultingBalanceLabel.text = Strings.resultingBalance
        resultingBalanceLabel.textColor = ColorName.battleshipGrey.color
        return resultingBalanceLabel
    }

}
