//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import ReplaceBrowserExtensionFacade
import Common

public class WalletSettingsApplicationService {

    public init() {}

    public func createRecoveryPhraseTransaction() -> TransactionData {
        let transactionID = DomainRegistry.settingsService.createReplaceRecoveryPhraseTransaction()
        DomainRegistry.settingsService.estimateRecoveryPhraseTransaction(transactionID)
        let tx = DomainRegistry.transactionRepository.findByID(transactionID)!
        return ApplicationServiceRegistry.recoveryService.transactionData(tx)
    }

    public func removeTransaction(_ id: String) {
        if let tx = DomainRegistry.transactionRepository.findByID(TransactionID(id)) {
            DomainRegistry.transactionRepository.remove(tx)
        }
    }

    public func isRecoveryPhraseTransactionReadyToStart(_ id: String) -> Bool {
        return DomainRegistry.settingsService.isRecoveryPhraseTransactionReadyToStart(TransactionID(id))
    }

    public func updateRecoveryPhraseTransaction(_ id: String, with account: String) {
        DomainRegistry.settingsService.updateRecoveryPhraseTransaction(TransactionID(id),
                                                                       with: Address(account))
    }

    public func cancelPhraseRecovery() {
        DomainRegistry.settingsService.cancelPhraseRecovery()
    }

}

extension WalletSettingsApplicationService: RBEStarter {

    public var replaceBrowserExtensionIsAvailable: Bool {
        return DomainRegistry.replaceExtensionService.isAvailable
    }

    public func create() -> RBETransactionID {
        return DomainRegistry.replaceExtensionService.createTransaction().id
    }

    public func estimate(transaction: RBETransactionID) -> RBEEstimationResult {
        let txID = TransactionID(transaction)
        DomainRegistry.replaceExtensionService.addDummyData(to: txID)
        do {
            let fee = try DomainRegistry.replaceExtensionService.estimateNetworkFee(for: txID)
            let negativeFee = TokenAmount(amount: -fee.amount, token: fee.token)
            let balance = DomainRegistry.replaceExtensionService.accountBalance(for: txID)
            let remaining = DomainRegistry.replaceExtensionService.resultingBalance(for: txID, change: negativeFee)
            var result = RBEEstimationResult(feeCalculation: nil, error: nil)
            result.feeCalculation =
                RBEFeeCalculationData(currentBalance: TokenData(token: balance.token, balance: balance.amount),
                                      networkFee: TokenData(token: negativeFee.token, balance: negativeFee.amount),
                                      balance: TokenData(token: remaining.token, balance: remaining.amount))
            if remaining.amount < 0 {
                result.error = FeeCalculationError.insufficientBalance
            }
            return result
        } catch let error {
            return RBEEstimationResult(feeCalculation: nil, error: error)
        }
    }

    public func start(transaction: RBETransactionID) throws {
        let txID = TransactionID(transaction)
        do {
            try DomainRegistry.replaceExtensionService.validate(transactionID: txID)
        } catch ReplaceBrowserExtensionDomainServiceError.browserExtensionNotConnected {

        } catch ReplaceBrowserExtensionDomainServiceError.insufficientBalance {
            throw FeeCalculationError.insufficientBalance
        }
    }

}

public extension WalletSettingsApplicationService {

     func connect(transaction: RBETransactionID, code: String) throws {
        let txID = TransactionID(transaction)
        if let oldPairAddress = DomainRegistry.replaceExtensionService.newOwnerAddress(from: txID) {
            try ApplicationServiceRegistry.walletService.deletePair(with: oldPairAddress)
        }
        try ApplicationServiceRegistry.walletService.createPair(from: code)
        let newAddress = ApplicationServiceRegistry.walletService.address(browserExtensionCode: code)
        DomainRegistry.replaceExtensionService.update(transaction: txID, newOwnerAddress: newAddress)
    }

}
