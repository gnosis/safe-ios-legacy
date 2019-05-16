//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication
import BigInt
import Common
import SafeUIKit

class SendInputViewModel {

    private var intFee: BigInt?

    private(set) var amount: BigInt?
    private(set) var recipient: String?

    private var feeTokenID: BaseID {
        return BaseID(ApplicationServiceRegistry.walletService.feePaymentTokenData.address)
    }
    private(set) var feeBalanceTokenData: TokenData!
    private(set) var feeAmountTokenData: TokenData!
    private(set) var feeResultingBalanceTokenData: TokenData!

    private(set) var resultingTokenData: TokenData!

    private(set) var canProceedToSigning: Bool

    private let inputQueue: OperationQueue
    private let transferTokenID: BaseID
    private(set) var accountBalanceTokenData: TokenData!

    private var walletService: WalletApplicationService { return ApplicationServiceRegistry.walletService }
    private let updateBlock: () -> Void

    init(tokenID: BaseID, processEventsOnMainThread: Bool = false, onUpdate: @escaping () -> Void) {
        self.transferTokenID = tokenID
        canProceedToSigning = false
        updateBlock = onUpdate
        accountBalanceTokenData = ApplicationServiceRegistry.walletService.tokenData(id: tokenID.id)!
        inputQueue = OperationQueue()
        inputQueue.maxConcurrentOperationCount = 1
        inputQueue.qualityOfService = .userInitiated
        // for unit testing purposes
        if processEventsOnMainThread {
            inputQueue.underlyingQueue = .main
        }
    }

    func start() {
        accountBalanceTokenData = ApplicationServiceRegistry.walletService.tokenData(id: transferTokenID.id)!
        updateFeeData()
        notifyUpdated()
        enqueueFeeEstimation()
    }

    func change(amount: BigInt) {
        guard amount != self.amount else { return }
        self.amount = amount
        enqueueFeeEstimation()
        updateResultingBalance()
        notifyUpdated()
    }

    func change(recipient: String?) {
        guard recipient != self.recipient else { return }
        self.recipient = recipient
        enqueueFeeEstimation()
        notifyUpdated()
    }

    private func enqueueFeeEstimation() {
        inputQueue.cancelAllOperations()
        inputQueue.addOperation(CancellableBlockOperation { [weak self] op in
            guard let `self` = self else { return }
            if op.isCancelled { return }
            self.intFee = self.walletService.estimateTransferFee(amount: self.amount ?? 0, address: self.recipient)
            if op.isCancelled { return }
            self.updateFeeData()
            self.notifyUpdated()
        })
    }

    private func notifyUpdated() {
        canProceedToSigning = hasEnoughFunds() == true && isValidAddress(recipient)
        if Thread.isMainThread {
            updateBlock()
        } else {
            DispatchQueue.main.sync(execute: updateBlock)
        }
    }

    private func updateFeeData() {
        guard let balance = self.walletService.tokenData(id: self.feeTokenID.id),
            balance.balance != nil else { return }
        self.feeBalanceTokenData = balance
        self.feeAmountTokenData = balance.withBalance(-(intFee ?? 0))
        self.updateResultingBalance()
    }

    private func updateResultingBalance() {
        let intAmount = amount ?? 0
        let feeAmount = abs(self.feeAmountTokenData?.balance ?? 0)
        let feeAccountbalance = self.feeBalanceTokenData?.balance ?? 0
        let accountBalance = self.accountBalanceTokenData.balance ?? 0
        if feeTokenID == transferTokenID {
            let newBalance = feeAccountbalance - intAmount - feeAmount
            self.feeResultingBalanceTokenData = self.feeBalanceTokenData.withBalance(newBalance)
        } else {
            self.resultingTokenData = self.accountBalanceTokenData.withBalance(accountBalance - intAmount)
            self.feeResultingBalanceTokenData = self.feeBalanceTokenData.withBalance(feeAccountbalance - feeAmount)
        }
    }

    private func isValidAddress(_ string: String?) -> Bool {
        if let string = string, EthereumAddressFormatter().string(from: string) != nil {
            return true
        }
        return false
    }

    func hasEnoughFunds() -> Bool? {
        let accountBalance = accountBalanceTokenData.balance ?? 0
        let intAmount = amount ?? 0
        let feeBalance = feeBalanceTokenData.balance ?? 0
        let feeAmount = abs(feeAmountTokenData.balance ?? 0)
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
