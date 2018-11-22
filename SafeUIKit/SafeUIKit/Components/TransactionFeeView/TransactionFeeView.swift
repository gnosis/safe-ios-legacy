//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import Common

public class TransactionFeeView: BaseCustomView {

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
    private let paddings: (left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat) = (16, 20, 16, 20)
    public private(set) var tokenFormatter: TokenNumberFormatter = .ERC20Token(decimals: 18)

    public var currentBalanceLabel: UILabel? {
        return label(at: IndexPath(item: 0, section: 0))
    }

    public var currentBalanceValueLabel: UILabel? {
        return label(at: IndexPath(item: 1, section: 0))
    }

    public var transactionFeeLabel: UILabel? {
        return label(at: IndexPath(item: 0, section: 1))
    }

    public var transactionFeeValueLabel: UILabel? {
        return label(at: IndexPath(item: 1, section: 1))
    }

    public var resultingBalanceLabel: UILabel? {
        return label(at: IndexPath(item: 0, section: wrapperStackView.arrangedSubviews.count - 1))
    }

    public var resultingBalanceValueLabel: UILabel? {
        return label(at: IndexPath(item: 1, section: wrapperStackView.arrangedSubviews.count - 1))
    }

    private func label(at path: IndexPath) -> UILabel? {
        guard wrapperStackView.arrangedSubviews.count > path.section,
            let stackView = (wrapperStackView.arrangedSubviews[path.section] as? UIStackView),
            stackView.arrangedSubviews.count > path.item else { return nil }
        return stackView.arrangedSubviews[path.item] as? UILabel
    }

    public override func commonInit() {
        backgroundColor = ColorName.paleGreyThree.color
        pinWrapperStackView()
    }

    private func pinWrapperStackView() {
        wrapperStackView.axis = .vertical
        wrapperStackView.spacing = 4
        wrapperStackView.accessibilityIdentifier = "wrapperStackView"
        wrapperStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(wrapperStackView)
        NSLayoutConstraint.activate([
            wrapperStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: paddings.left),
            wrapperStackView.topAnchor.constraint(equalTo: topAnchor, constant: paddings.top),
            wrapperStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -paddings.right),
            wrapperStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -paddings.bottom)])
    }

    public func configure(currentBalance: TokenData?, transactionFee: TokenData?, resultingBalance: TokenData!) {
        guard wrapperStackView.arrangedSubviews.isEmpty else { return }
        tokenFormatter = TokenNumberFormatter.ERC20Token(code: resultingBalance.code,
                                                         decimals: resultingBalance.decimals,
                                                         displayedDecimals: displayedDecimals)
        let isSecondaryView = currentBalance == nil
        if let currentBalance = currentBalance {
            assert(currentBalance.isSameToken(with: resultingBalance))
            addCurrentBalance(currentBalance)
        }
        if let transactionFee = transactionFee {
            assert(transactionFee.isSameToken(with: resultingBalance))
            addTransactionFee(transactionFee, isSecondaryView: isSecondaryView)
        } else if !isSecondaryView {
            wrapperStackView.spacing = 8
        }
        addResultingBalance(resultingBalance, isSecondaryView: isSecondaryView)
    }

    private func addCurrentBalance(_ currentBalance: TokenData) {
        let currentBalanceStackView = balanceStackView(text: currentBalanceLabel(currentBalance),
                                                       balance: balanceLabel(currentBalance,
                                                                             bold: true,
                                                                             displayedDecimals: displayedDecimals))
        wrapperStackView.addArrangedSubview(currentBalanceStackView)
    }

    private func addTransactionFee(_ transactionFee: TokenData, isSecondaryView: Bool) {
        let transactionFeeStackView =
            balanceStackView(text: transactionFeeLabel(transactionFee,
                                                       shouldDisplayEtherText: isSecondaryView),
                             balance: balanceLabel(transactionFee,
                                                   bold: false,
                                                   displayedDecimals: displayedDecimals))
        wrapperStackView.addArrangedSubview(transactionFeeStackView)
        if !isSecondaryView {
            addSpacingView()
        }
    }

    private func addResultingBalance(_ resultingBalance: TokenData, isSecondaryView: Bool) {
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
        balanceLabel.text = tokenFormatter.string(from: tokenData.balance ?? 0)
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

    private func addSpacingView() {
        let emptyView = UIView()
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.heightAnchor.constraint(equalToConstant: 6).isActive = true
        wrapperStackView.addArrangedSubview(emptyView)
    }

}
