//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication
import BigInt
import Common
import SafeUIKit

class SendInputViewModel {

    private(set) var amount: BigInt?
    private(set) var recipient: String?
    private(set) var estimatedFee: BigInt?

    private let transferTokenID: BaseID
    private var feeTokenID: BaseID {
        return BaseID(ApplicationServiceRegistry.walletService.feePaymentTokenData.address)
    }

    var accountBalanceTokenData: TokenData {
        return ApplicationServiceRegistry.walletService.tokenData(id: transferTokenID.id)!
    }
    private(set) var resultingBalanceTokenData: TokenData!

    private(set) var feeBalanceTokenData: TokenData!
    private(set) var feeEstimatedAmountTokenData: TokenData!
    private(set) var feeResultingBalanceTokenData: TokenData!

    private(set) var canProceedToSigning: Bool

    private var walletService: WalletApplicationService { return ApplicationServiceRegistry.walletService }
    private let updateBlock: () -> Void
    private let inputQueue: OperationQueue

    init(tokenID: BaseID, processEventsOnMainThread: Bool = false, onUpdate: @escaping () -> Void) {
        self.transferTokenID = tokenID
        canProceedToSigning = false
        updateBlock = onUpdate
        inputQueue = OperationQueue()
        inputQueue.maxConcurrentOperationCount = 1
        inputQueue.qualityOfService = .userInitiated
        // for unit testing purposes
        if processEventsOnMainThread {
            inputQueue.underlyingQueue = .main
        }
    }

    func resetEstimation() {
        estimatedFee = nil
    }

    func update() {
        enqueueFeeEstimation()
        updateBalances()
    }

    func change(amount: BigInt) {
        guard amount != self.amount else { return }
        self.amount = amount
        update()
    }

    func change(recipient: String?) {
        guard recipient != self.recipient else { return }
        self.recipient = recipient
        update()
    }

    private func enqueueFeeEstimation() {
        inputQueue.cancelAllOperations()
        inputQueue.addOperation(CancellableBlockOperation { [weak self] op in
            guard let `self` = self else { return }
            if op.isCancelled { return }
            self.estimatedFee = self.walletService.estimateTransferFee(amount: self.amount ?? 0,
                                                                       address: self.recipient)
            if op.isCancelled { return }
            self.updateBalances()
        })
    }

    private func updateBalances() {
        updateFeeData()
        updateResultingData()
        notifyUpdated()
    }

    private func updateFeeData() {
        let feeTokenBalance = self.walletService.tokenData(id: self.feeTokenID.id)!
        self.feeBalanceTokenData = feeTokenBalance
        self.feeEstimatedAmountTokenData = feeTokenBalance.withBalance(estimatedFee != nil ? -estimatedFee! : nil)
    }

    private func updateResultingData() {
        let intAmount = amount ?? 0
        let feeAmount = abs(self.feeEstimatedAmountTokenData.balance ?? 0)
        let feeAccountbalance = self.feeBalanceTokenData.balance ?? 0
        let accountBalance = self.accountBalanceTokenData.balance ?? 0
        if feeTokenID == transferTokenID {
            let newBalance = feeAccountbalance - intAmount - feeAmount
            self.feeResultingBalanceTokenData = self.feeBalanceTokenData.withBalance(newBalance)
        } else {
            self.resultingBalanceTokenData = self.accountBalanceTokenData.withBalance(accountBalance - intAmount)
            self.feeResultingBalanceTokenData = self.feeBalanceTokenData.withBalance(feeAccountbalance - feeAmount)
        }
    }

    private func notifyUpdated() {
        canProceedToSigning = hasEnoughFunds() == true && isValidAddress(recipient)
        if Thread.isMainThread {
            updateBlock()
        } else {
            DispatchQueue.main.sync(execute: updateBlock)
        }
    }

    private func isValidAddress(_ string: String?) -> Bool {
        if let string = string, EthereumAddressFormatter().string(from: string) != nil {
            return true
        }
        return false
    }

    /// Checks if token to transfer has enough together with fees to be payed. If fee is not known, returns false.
    func hasEnoughFunds() -> Bool {
        guard let estimatedAmount = feeEstimatedAmountTokenData.balance else {
            return false
        }
        let accountBalance = accountBalanceTokenData.balance ?? 0
        let intAmount = amount ?? 0
        let feeBalance = feeBalanceTokenData.balance ?? 0
        let feeAmount = abs(estimatedAmount)
        if feeTokenID == transferTokenID {
            return accountBalance >= intAmount + feeAmount
        } else {
            return accountBalance >= intAmount && feeBalance >= feeAmount
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
