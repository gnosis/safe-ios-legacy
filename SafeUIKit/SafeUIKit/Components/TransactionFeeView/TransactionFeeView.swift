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
    internal let fontSize: CGFloat = 16
    private let displayedDecimals = 5
    private let stackViewSpacing: CGFloat = 8
    private let emptyViewHeight: CGFloat = 6
    private let paddings: (left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat) = (16, 25, 16, 25)
    public private(set) var tokenFormatter: TokenNumberFormatter = .ERC20Token(decimals: 18)

    public private(set) var currentBalance: TokenData?
    public private(set) var transactionFee: TokenData?
    public private(set) var resultingBalance: TokenData?

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
        backgroundColor = .white
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

    public func configure(currentBalance: TokenData?, transactionFee: TokenData?, resultingBalance: TokenData?) {
        self.currentBalance = currentBalance
        self.transactionFee = transactionFee
        self.resultingBalance = resultingBalance
        if let resultingBalance = resultingBalance {
            tokenFormatter.tokenCode = resultingBalance.code
            tokenFormatter.decimals = resultingBalance.decimals
        }
        tokenFormatter.displayedDecimals = displayedDecimals
        buildWrapperStackView()
        updateValues()
    }

    private func buildWrapperStackView() {
        wrapperStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if let section = currentBalanceSection() {
            wrapperStackView.addArrangedSubview(section)
        }
        if let section = transactionFeeSection() {
            wrapperStackView.addArrangedSubview(section)
        }
        if transactionFee != nil && !isSecondaryView {
            wrapperStackView.addArrangedSubview(spacingView())
        } else if transactionFee == nil {
            wrapperStackView.spacing = stackViewSpacing
        }
        wrapperStackView.addArrangedSubview(resultingBalanceSection())
    }

    private func updateValues() {
        if let data = currentBalance {
            currentBalanceValueLabel?.text = tokenFormatter.string(from: data.balance ?? 0)
        }
        if let data = transactionFee {
            transactionFeeValueLabel?.text = tokenFormatter.string(from: data.balance ?? 0)
        }
        if let data = resultingBalance {
            resultingBalanceValueLabel?.text = tokenFormatter.string(from: data.balance ?? 0)
        }
    }

    private func currentBalanceSection() -> UIStackView? {
        guard let tokenData = currentBalance, let resultingBalance = resultingBalance else { return nil }
        assert(tokenData.isSameToken(with: resultingBalance))
        return sectionStackView(text: currentBalanceLabel(tokenData),
                                balance: tokenValueLabel(tokenData, bold: true))
    }

    private func transactionFeeSection() -> UIStackView? {
        guard let tokenData = transactionFee, let resultingBalance = resultingBalance else { return nil }
        assert(tokenData.isSameToken(with: resultingBalance))
        return sectionStackView(text: transactionFeeLabel(tokenData, shouldDisplayEtherText: isSecondaryView),
                                balance: tokenValueLabel(tokenData, bold: false))
    }

    private func resultingBalanceSection() -> UIStackView {
        guard let resultingBalance = resultingBalance else { return UIStackView() }
        let isBold = !isSecondaryView
        return sectionStackView(text: resultingBalanceLabel(resultingBalance, bold: isBold),
                                balance: tokenValueLabel(resultingBalance, bold: isBold))
    }

    private func sectionStackView(text: UILabel, balance: UILabel) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = stackViewSpacing
        stackView.addArrangedSubview(text)
        stackView.addArrangedSubview(balance)
        return stackView
    }

    private func currentBalanceLabel(_ tokenData: TokenData) -> UILabel {
        return baseLabel(Strings.currentBalance + (!tokenData.isEther ? " (\(Strings.token))" : ""), bold: true)
    }

    private func resultingBalanceLabel(_ tokenData: TokenData, bold: Bool) -> UILabel {
        return baseLabel(Strings.resultingBalance, bold: bold)
    }

    private func transactionFeeLabel(_ tokenData: TokenData, shouldDisplayEtherText: Bool) -> UILabel {
        return baseLabel(Strings.transactionFee + (shouldDisplayEtherText ? " (\(Strings.ether))" :  ""), bold: false)
    }

    private func tokenValueLabel(_ tokenData: TokenData, bold: Bool) -> UILabel {
        let label = baseLabel(tokenFormatter.string(from: tokenData.balance ?? 0), bold: bold)
        label.textAlignment = .right
        label.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
        return label
    }

    private func baseLabel(_ text: String, bold: Bool) -> UILabel {
        let label = UILabel()
        label.font = bold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
        label.textColor = ColorName.battleshipGrey.color
        label.text = text
        return label
    }

    private func spacingView() -> UIView {
        let emptyView = UIView()
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.heightAnchor.constraint(equalToConstant: emptyViewHeight).isActive = true
        return emptyView
    }

}
