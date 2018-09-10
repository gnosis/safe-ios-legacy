//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication
import BigInt
import Common
import SafeUIKit

class FundsTransferTransactionViewModel {

    private (set) var intAmount: BigInt?
    private var intBalance: BigInt?
    private var intFee: BigInt?

    private(set) var senderName: String
    private(set) var senderAddress: String
    private(set) var balance: String?
    private(set) var amount: String?
    private(set) var recipient: String?
    private(set) var fee: String
    private(set) var canProceedToSigning: Bool

    private(set) var amountErrors = [Error]()
    private(set) var recipientErrors = [Error]()

    private var allErrors: [Error] { return amountErrors + recipientErrors }
    private var hasErrors: Bool { return !allErrors.isEmpty }

    let tokenFormatter: TokenNumberFormatter = .eth
    private let amountValidator: TokenAmountValidator
    private let fundsValidator: FundsValidator
    private let addressValidator: EthereumAddressValidator
    private let inputQueue: OperationQueue
    private let tokenID: BaseID!

    private var walletService: WalletApplicationService { return ApplicationServiceRegistry.walletService }

    private let updateBlock: () -> Void

    init(senderName: String, tokenID: BaseID, onUpdate: @escaping () -> Void) {
        self.senderName = senderName
        self.tokenID = tokenID
        self.senderAddress = ApplicationServiceRegistry.walletService.selectedWalletAddress!
        canProceedToSigning = false
        updateBlock = onUpdate
        amountValidator = TokenAmountValidator(formatter: tokenFormatter, range: BigInt(0)..<BigInt(2).power(256) - 1)
        fundsValidator = FundsValidator()
        addressValidator = EthereumAddressValidator(byteCount: 20)
        fee = "--"
        inputQueue = OperationQueue()
        inputQueue.maxConcurrentOperationCount = 1
        inputQueue.qualityOfService = .userInitiated
    }

    func start() {
        updateBalance()
        enqueueFeeEstimation()
    }

    private func updateBalance() {
        if let value = walletService.accountBalance(tokenID: tokenID) {
            intBalance = BigInt(value)
            balance = tokenFormatter.string(from: intBalance!)
        } else {
            intBalance = nil
            balance = nil
        }
        updateCanProceedToSigning()
        notifyUpdated()
    }

    private func notifyUpdated() {
        if Thread.isMainThread {
            updateBlock()
        } else {
            DispatchQueue.main.sync(execute: updateBlock)
        }
    }

    func change(amount: String?) {
        guard amount != self.amount else { return }
        self.amount = amount
        didChangeAmount()
    }

    private func didChangeAmount() {
        updateIntAmount()
        clearAmountErrors()
        validateAmount()
        validateFunds()
        updateCanProceedToSigning()
        notifyUpdated()
    }

    func change(recipient: String?) {
        guard recipient != self.recipient else { return }
        self.recipient = recipient
        didChangeRecipient()
    }

    private func didChangeRecipient() {
        clearRecipientErrors()
        validateRecipient()
        if recipientErrors.isEmpty {
            enqueueFeeEstimation()
        }
        updateCanProceedToSigning()
        notifyUpdated()
    }

    private func clearRecipientErrors() {
        recipientErrors = []
    }

    private func validateRecipient() {
        guard let recipient = recipient else { return }
        if let error = addressValidator.validate(recipient) {
            recipientErrors.append(error)
        }
    }

    private func updateIntAmount() {
        guard let amount = amount else { intAmount = nil; return }
        intAmount = tokenFormatter.number(from: amount)
    }

    private func clearAmountErrors() {
        amountErrors = []
    }

    private func validateAmount() {
        guard let amount = amount else { return }
        if let error = amountValidator.validate(amount) {
            amountErrors.append(error)
        }
    }

    private func enqueueFeeEstimation() {
        let intAmount = self.intAmount
        let recipient = self.recipient
        inputQueue.cancelAllOperations()
        inputQueue.addOperation(CancellableBlockOperation { [weak self] op in
            guard let `self` = self else { return }
            if op.isCancelled { return }
            let intFee = self.walletService.estimateTransferFee(amount: intAmount ?? 0, address: recipient)
            if op.isCancelled { return }
            self.intFee = intFee
            self.fee = intFee == nil ? "--" : self.tokenFormatter.string(from: -intFee!)
            self.didChangeFee()
        })
    }

    private func didChangeFee() {
        validateFunds()
        updateCanProceedToSigning()
        notifyUpdated()
    }

    private func updateCanProceedToSigning() {
        guard let balance = intBalance, let amount = intAmount, let fee = intFee,
            !hasErrors, recipient != nil else {
                canProceedToSigning = false
                return
        }
        canProceedToSigning = amount + fee <= balance
    }

    private func validateFunds() {
        guard amountErrors.isEmpty else { return }
        if let amount = intAmount, let fee = intFee, let balance = intBalance,
            let error = fundsValidator.validate(amount, fee, balance) {
            amountErrors.append(error)
        }
    }

}

fileprivate class CancellableBlockOperation: Operation {

    let block: (CancellableBlockOperation) -> Void

    init(block: @escaping (CancellableBlockOperation) -> Void) {
        self.block = block
    }

    override func main() {
        block(self)
    }

}
