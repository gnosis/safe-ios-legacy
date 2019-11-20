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
        let walletID = ApplicationServiceRegistry.walletService.selectedWalletID()!
        return ApplicationServiceRegistry.walletService.tokenData(id: transferTokenID.id,
                                                                  walletID: walletID)!
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
        ApplicationServiceRegistry.walletService.subscribeForBalanceUpdates(subscriber: self)
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
                                                                       recipientAddress: self.recipient,
                                                                       token: self.transferTokenID.id,
                                                                       feeToken: self.feeTokenID.id)
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
        let walletID = ApplicationServiceRegistry.walletService.selectedWalletID()!
        let fee = self.walletService.tokenData(id: self.feeTokenID.id, walletID: walletID)!
        feeBalanceTokenData = fee
        feeEstimatedAmountTokenData = fee.withBalance(estimatedFee != nil ? -estimatedFee! : nil)
    }

    private func updateResultingData() {
        let intAmount = amount ?? 0
        let feeAmount = abs(feeEstimatedAmountTokenData.balance ?? 0)
        let feeAccountbalance = feeBalanceTokenData.balance ?? 0
        let accountBalance = accountBalanceTokenData.balance ?? 0
        if feeTokenID == transferTokenID {
            let newBalance = feeAccountbalance - intAmount - feeAmount
            feeResultingBalanceTokenData = feeBalanceTokenData.withBalance(newBalance)
        } else {
            resultingBalanceTokenData = accountBalanceTokenData.withBalance(accountBalance - intAmount)
            feeResultingBalanceTokenData = feeBalanceTokenData.withBalance(feeAccountbalance - feeAmount)
        }
    }

    private func notifyUpdated() {
        canProceedToSigning = hasEnoughFunds() == true && isValidAddress(recipient)
        if Thread.isMainThread {
            updateBlock()
        } else {
            DispatchQueue.main.sync { [unowned self] in
                self.updateBlock()
            }
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

extension SendInputViewModel: EventSubscriber {

    func notify() {
        updateBalances()
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
