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
    private var intFee: BigInt?
    public var balance: String {
        return tokenFormatter.string(from: tokenData.balance ?? 0)
    }
    private(set) var tokenData: TokenData!
    private(set) var amount: String?
    private(set) var recipient: String?

    private(set) var feeBalanceTokenData: TokenData!
    private(set) var feeResultingBalanceTokenData: TokenData!
    private(set) var feeAmountTokenData: TokenData!
    private(set) var resultingTokenData: TokenData!

    private(set) var canProceedToSigning: Bool
    let tokenFormatter: TokenNumberFormatter = .ERC20Token(decimals: 18)
    private let inputQueue: OperationQueue
    private let tokenID: BaseID!
    private let feeTokenID: BaseID = ethID
    private var walletService: WalletApplicationService { return ApplicationServiceRegistry.walletService }
    private let updateBlock: () -> Void

    init(tokenID: BaseID, onUpdate: @escaping () -> Void) {
        self.tokenID = tokenID
        canProceedToSigning = false
        updateBlock = onUpdate
        tokenData = ApplicationServiceRegistry.walletService.tokenData(id: tokenID.id)!
        tokenFormatter.decimals = tokenData.decimals
        tokenFormatter.displayedDecimals = 8
        inputQueue = OperationQueue()
        inputQueue.maxConcurrentOperationCount = 1
        inputQueue.qualityOfService = .userInitiated
    }

    func start() {
        updateBalance()
        enqueueFeeEstimation()
    }

    private func updateBalance() {
        self.tokenData = ApplicationServiceRegistry.walletService.tokenData(id: tokenID.id)!
        self.updateFeeData()
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

    func change(recipient: String?) {
        guard recipient != self.recipient else { return }
        self.recipient = recipient
        didChangeRecipient()
    }

    private func didChangeAmount() {
        updateIntAmount()
        if intAmount != nil {
            enqueueFeeEstimation()
        }
        updateResultingBalance()
        updateCanProceedToSigning()
        notifyUpdated()
    }

    private func didChangeRecipient() {
        if recipient != nil {
            enqueueFeeEstimation()
        }
        updateCanProceedToSigning()
        notifyUpdated()
    }

    private func didChangeFee() {
        updateCanProceedToSigning()
        notifyUpdated()
    }

    private func updateIntAmount() {
        guard let amount = amount else { intAmount = nil; return }
        intAmount = tokenFormatter.number(from: amount)
    }

    private func enqueueFeeEstimation() {
        let intAmount = self.intAmount
        let recipient = self.recipient
        inputQueue.cancelAllOperations()
        inputQueue.addOperation(CancellableBlockOperation { [weak self] op in
            guard let `self` = self else { return }
            if op.isCancelled { return }
            self.intFee = self.walletService.estimateTransferFee(amount: intAmount ?? 0, address: recipient)
            if op.isCancelled { return }
            self.updateFeeData()
            self.didChangeFee()
        })
    }

    private func updateFeeData() {
        guard let balance = self.walletService.tokenData(id: self.feeTokenID.id),
            balance.balance != nil else { return }
        self.feeBalanceTokenData = balance
        self.feeAmountTokenData = balance.withBalance(-(intFee ?? 0))
        self.updateResultingBalance()
    }

    private func updateResultingBalance() {
        let intAmount = self.intAmount ?? 0
        let feeAmount = abs(self.feeAmountTokenData?.balance ?? 0)
        let feeAccountbalance = self.feeBalanceTokenData?.balance ?? 0
        let accountBalance = self.tokenData.balance ?? 0
        if feeTokenID == tokenID {
            let newBalance = feeAccountbalance - intAmount - feeAmount
            self.feeResultingBalanceTokenData = self.feeBalanceTokenData.withBalance(newBalance)
        } else {
            self.resultingTokenData = self.tokenData.withBalance(accountBalance - intAmount)
            self.feeResultingBalanceTokenData = self.feeBalanceTokenData.withBalance(feeAccountbalance - feeAmount)
        }
    }

    private func updateCanProceedToSigning() {
        canProceedToSigning = hasEnoughFunds() == true && recipient != nil
    }

    func hasEnoughFunds() -> Bool? {
        let accountBalance = tokenData.balance ?? 0
        let amount = intAmount ?? 0
        let feeBalance = feeBalanceTokenData.balance ?? 0
        let feeAmount = abs(feeAmountTokenData.balance ?? 0)
        if feeTokenID == tokenID {
            return accountBalance >= amount + feeAmount
        } else {
            return accountBalance >= amount && feeBalance >= feeAmount
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
