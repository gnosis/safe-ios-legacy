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

    internal let wrapperStackView = UIStackView()
    private let displayedDecimals = 5
    private let paddings: (left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat) = (16, 20, 16, 20)
    public private(set) var tokenFormatter: TokenNumberFormatter = .ERC20Token(decimals: 18)

    private var currentBalance: TokenData?
    private var transactionFee: TokenData?
    private var resultingBalance: TokenData!

    private var isSecondaryView: Bool {
        return currentBalanceLabel == nil
    }

    public var currentBalanceLabel: UILabel? {
        guard currentBalance != nil else { return nil }
        return label(at: IndexPath(item: 0, section: 0))
    }

    public var currentBalanceValueLabel: UILabel? {
        guard currentBalance != nil else { return nil }
        return label(at: IndexPath(item: 1, section: 0))
    }

    public var transactionFeeLabel: UILabel? {
        guard transactionFee != nil else { return nil }
        return label(at: IndexPath(item: 0, section: currentBalance == nil ? 0 : 1))
    }

    public var transactionFeeValueLabel: UILabel? {
        guard transactionFee != nil else { return nil }
        return label(at: IndexPath(item: 1, section: currentBalance == nil ? 0 : 1))
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
        self.currentBalance = currentBalance
        self.transactionFee = transactionFee
        self.resultingBalance = resultingBalance
        tokenFormatter = TokenNumberFormatter.ERC20Token(code: resultingBalance.code,
                                                         decimals: resultingBalance.decimals,
                                                         displayedDecimals: displayedDecimals)
        buildWrapperStackView()
    }

    private func buildWrapperStackView() {
        guard wrapperStackView.arrangedSubviews.isEmpty else { return }
        if let section = currentBalanceSection() {
            wrapperStackView.addArrangedSubview(section)
        }
        if let section = transactionFeeSection() {
            wrapperStackView.addArrangedSubview(section)
        }
        if transactionFee != nil && !isSecondaryView {
            wrapperStackView.addArrangedSubview(spacingView())
        } else if transactionFee == nil {
            wrapperStackView.spacing = 8
        }
        wrapperStackView.addArrangedSubview(resultingBalanceSection())
    }

    private func currentBalanceSection() -> UIStackView? {
        guard let tokenData = currentBalance else { return nil }
        assert(tokenData.isSameToken(with: resultingBalance))
        return sectionStackView(text: currentBalanceLabel(tokenData),
                                balance: tokenValueLabel(tokenData, bold: true))
    }

    private func transactionFeeSection() -> UIStackView? {
        guard let tokenData = transactionFee else { return nil }
        assert(tokenData.isSameToken(with: resultingBalance))
        return sectionStackView(text: transactionFeeLabel(tokenData, shouldDisplayEtherText: isSecondaryView),
                                balance: tokenValueLabel(tokenData, bold: false))
    }

    private func resultingBalanceSection() -> UIStackView {
        let isBold = !isSecondaryView
        return sectionStackView(text: resultingBalanceLabel(resultingBalance, bold: isBold),
                                balance: tokenValueLabel(resultingBalance, bold: isBold))
    }

    private func sectionStackView(text: UILabel, balance: UILabel) -> UIStackView {
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
        currentBalanceLabel.textColor = ColorName.battleshipGrey.color
        currentBalanceLabel.text = Strings.currentBalance + (!tokenData.isEther ? " (\(Strings.token))" : "")
        return currentBalanceLabel
    }

    private func tokenValueLabel(_ tokenData: TokenData, bold: Bool) -> UILabel {
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
        transactionFeeLabel.textColor = ColorName.battleshipGrey.color
        transactionFeeLabel.text = Strings.transactionFee + (shouldDisplayEtherText ? " (\(Strings.ether))" :  "")
        return transactionFeeLabel
    }

    private func resultingBalanceLabel(_ tokenData: TokenData, bold: Bool) -> UILabel {
        let resultingBalanceLabel = UILabel()
        resultingBalanceLabel.font = bold ? UIFont.boldSystemFont(ofSize: 16) : UIFont.systemFont(ofSize: 16)
        resultingBalanceLabel.text = Strings.resultingBalance
        resultingBalanceLabel.textColor = ColorName.battleshipGrey.color
        return resultingBalanceLabel
    }

    private func spacingView() -> UIView {
        let emptyView = UIView()
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.heightAnchor.constraint(equalToConstant: 6).isActive = true
        return emptyView
    }

}
