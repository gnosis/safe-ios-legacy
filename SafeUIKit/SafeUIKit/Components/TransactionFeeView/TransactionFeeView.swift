//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import Common

public class TransactionFeeView: BaseCustomView {

    enum Strings {
        static let currentBalance = LocalizedString("transaction_fee.current_balance", comment: "Current balance")
        static let transactionFee = LocalizedString("transaction_fee", comment: "Transaction fee")
        static let resultingBalance = LocalizedString("balance_after_transfer",
                                                      comment: "Balance after transfer")
        static let ether = LocalizedString("transaction_fee.ether", comment: "Displayed in parentheses")
        static let token = LocalizedString("transaction_fee.token", comment: "Displayed in parentheses")
        static let noFunds = LocalizedString("transaction_fee.insufficient_funds",
                                             comment: "Warning about not enough funds")
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
        let stack = view(at: IndexPath(item: 0, section: currentBalance == nil ? 0 : 1)) as? UIStackView
        let label = stack?.arrangedSubviews.first as? UILabel
        return label
    }

    public var transactionFeeInfoButton: UIButton? {
        guard transactionFee != nil else { return nil }
        let stack = view(at: IndexPath(item: 0, section: currentBalance == nil ? 0 : 1)) as? UIStackView
        let label = stack?.arrangedSubviews.last as? UIButton
        return label
    }

    public var transactionFeeValueLabel: UILabel? {
        guard transactionFee != nil else { return nil }
        return label(at: IndexPath(item: 1, section: currentBalance == nil ? 0 : 1))
    }

    // wrapper -> v_stack -> [h_stack, label] -> [[label, imageview], label]
    public var resultingBalanceLabel: UILabel? {
        let path = IndexPath(item: 0, section: wrapperStackView.arrangedSubviews.count - 1)
        let lineStack = view(at: path) as? UIStackView
        let stack = lineStack?.arrangedSubviews.first as? UIStackView
        let label = stack?.arrangedSubviews.first as? UILabel
        return label
    }

    public var resultingBalanceErrorImageView: UIImageView? {
        let path = IndexPath(item: 0, section: wrapperStackView.arrangedSubviews.count - 1)
        let lineStack = view(at: path) as? UIStackView
        let stack = lineStack?.arrangedSubviews.first as? UIStackView
        let imageView = stack?.arrangedSubviews.last as? UIImageView
        return imageView
    }

    public var resultingBalanceValueLabel: UILabel? {
        let path = IndexPath(item: 0, section: wrapperStackView.arrangedSubviews.count - 1)
        let lineStack = view(at: path) as? UIStackView
        return lineStack?.arrangedSubviews.last as? UILabel
    }

    public var resultingBalanceErrorLabel: UILabel? {
        return label(at: IndexPath(item: 1, section: wrapperStackView.arrangedSubviews.count - 1))
    }

    private func label(at path: IndexPath) -> UILabel? {
        guard wrapperStackView.arrangedSubviews.count > path.section,
            let stackView = (wrapperStackView.arrangedSubviews[path.section] as? UIStackView),
            stackView.arrangedSubviews.count > path.item else { return nil }
        return stackView.arrangedSubviews[path.item] as? UILabel
    }

    private func view(at path: IndexPath) -> UIView? {
        guard wrapperStackView.arrangedSubviews.count > path.section,
            let stackView = (wrapperStackView.arrangedSubviews[path.section] as? UIStackView),
            stackView.arrangedSubviews.count > path.item else { return nil }
        return stackView.arrangedSubviews[path.item]
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
            let hasEnoughFunds = (data.balance ?? 0) >= 0
            resultingBalanceErrorImageView?.isHidden = hasEnoughFunds
            resultingBalanceErrorLabel?.isHidden = hasEnoughFunds
            let textColor = hasEnoughFunds ? ColorName.battleshipGrey.color : ColorName.tomato.color
            resultingBalanceValueLabel?.textColor = textColor
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
        let horizontalStack = sectionStackView(text: resultingBalanceLabel(resultingBalance, bold: isBold),
                                               balance: tokenValueLabel(resultingBalance, bold: isBold))
        let errorLabel = UILabel()
        errorLabel.font = UIFont.systemFont(ofSize: 14)
        errorLabel.textColor = ColorName.tomato.color
        errorLabel.text = Strings.noFunds
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        let verticalStack = UIStackView(arrangedSubviews: [horizontalStack, errorLabel])
        verticalStack.axis = .vertical
        return verticalStack
    }

    private func sectionStackView(text: UIView, balance: UILabel) -> UIStackView {
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

    private func resultingBalanceLabel(_ tokenData: TokenData, bold: Bool) -> UIView {
        let label = baseLabel(Strings.resultingBalance, bold: bold)
        label.setContentHuggingPriority(.required, for: .horizontal)
        let errorIcon = UIImageView(image: Asset.error.image)
        errorIcon.frame = CGRect(x: 0, y: 0, width: 16, height: 16)
        errorIcon.isHidden = true
        errorIcon.contentMode = .center
        let stack = UIStackView(arrangedSubviews: [label, errorIcon])
        stack.axis = .horizontal
        stack.spacing = 4
        return stack
    }

    private func transactionFeeLabel(_ tokenData: TokenData, shouldDisplayEtherText: Bool) -> UIView {
        let text = Strings.transactionFee + (shouldDisplayEtherText ? " (\(Strings.ether))" :  "")
        let label = baseLabel(text, bold: false)
        label.setContentHuggingPriority(.required, for: .horizontal)
        let button = UIButton(type: .custom)
        button.setTitle("[?]", for: .normal)
        button.setTitleColor(ColorName.aquaBlue.color, for: .normal)
        button.addTarget(nil, action: Selector(("showTransactionFeeInfo")), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [label, button])
        stack.axis = .horizontal
        return stack
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
