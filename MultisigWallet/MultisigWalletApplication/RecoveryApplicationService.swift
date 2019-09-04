//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import Common

public enum RecoveryApplicationServiceError: Error {
    case invalidContractAddress
    case recoveryPhraseInvalid
    case recoveryAccountsNotFound
    case unsupportedOwnerCount
    case unsupportedWalletConfiguration
    case failedToChangeOwners
    case failedToChangeConfirmationCount
    case failedToCreateValidTransactionData
    case walletNotFound
    case failedToCreateValidTransaction
    case internalServerError
}

public class RecoveryApplicationService {

    public init() {}

    public func createRecoverDraftWallet() {
        DomainRegistry.recoveryService.createRecoverDraftWallet()
    }

    public func prepareForRecovery() {
        // remove all owners, recreate new owner
        DomainRegistry.recoveryService.prepareForRecovery()
    }

    public func validate(address: String,
                         subscriber: EventSubscriber,
                         onError errorHandler: @escaping (Error) -> Void) {
        withEnvironment(for: subscriber, errorHandler: errorHandler) {
            ApplicationServiceRegistry.eventRelay.subscribe(subscriber, for: WalletAddressChanged.self)
            DomainRegistry.recoveryService.change(address: Address(address))
        }
    }

    public func provide(recoveryPhrase: String,
                        subscriber: EventSubscriber,
                        onError errorHandler: @escaping (Error) -> Void) {
        withEnvironment(for: subscriber, errorHandler: errorHandler) {
            ApplicationServiceRegistry.eventRelay.subscribe(subscriber, for: WalletRecoveryAccountsAccepted.self)
            DomainRegistry.recoveryService.provide(recoveryPhrase: recoveryPhrase)
        }
    }

    public func estimateRecoveryTransaction() -> [TokenData] {
        return DomainRegistry.recoveryService.estimateRecoveryTransaction()
    }

    public func createRecoveryTransaction(subscriber: EventSubscriber,
                                          onError errorHandler: @escaping (Error) -> Void) {
        withEnvironment(for: subscriber, errorHandler: errorHandler) {
            ApplicationServiceRegistry.eventRelay.subscribe(subscriber, for: WalletBecameReadyForRecovery.self)
            ApplicationServiceRegistry.eventRelay.subscribe(subscriber, for: AccountsBalancesUpdated.self)
            DomainRegistry.recoveryService.createRecoveryTransaction()
        }
    }

    public func recoveryTransaction() -> TransactionData? {
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        guard let tx = DomainRegistry.transactionRepository.find(type: .walletRecovery, wallet: wallet.id) else {
            return nil
        }
        return transactionData(tx)
    }

    public func transactionData(_ tx: String) -> TransactionData {
        let tx = DomainRegistry.transactionRepository.find(id: TransactionID(tx))!
        return transactionData(tx)
    }

    // swiftlint:disable:next cyclomatic_complexity
    public func transactionData(_ tx: Transaction) -> TransactionData {
        let status: TransactionData.Status
        switch tx.status {
        case .draft:
            status = .waitingForConfirmation
        case .signing:
            status = .readyToSubmit
        case .pending:
            status = .pending
        case .rejected:
            status = .rejected
        case .failed:
            status = .failed
        case .success:
            status = .success
        }
        let type: TransactionData.TransactionType
        switch tx.type {
        case .transfer:
            type = .outgoing
        case .walletRecovery:
            type = .walletRecovery
        case .replaceRecoveryPhrase:
            type = .replaceRecoveryPhrase
        case .replaceBrowserExtension:
            type = .replaceBrowserExtension
        case .connectBrowserExtension:
            type = .connectBrowserExtension
        case .disconnectBrowserExtension:
            type = .disconnectBrowserExtension
        case .contractUpgrade:
            type = .contractUpgrade
        }
        let amount = tx.amount ?? TokenAmount(amount: 0, token: Token.Ether)
        let amountTokenData = TokenData(token: amount.token, balance: amount.amount)
        let paymentToken = WalletDomainService.token(id: tx.accountID.tokenID.id) ?? Token.Ether
        let zeroGasPrice = TokenAmount(amount: 0, token: paymentToken)
        let zeroFeeEstimate = TransactionFeeEstimate(gas: 0, dataGas: 0, operationalGas: 0, gasPrice: zeroGasPrice)
        let feeEstimate = tx.feeEstimate ?? zeroFeeEstimate
        let feeTokenData = TokenData(token: paymentToken, balance: -feeEstimate.totalDisplayedToUser.amount)
        return TransactionData(id: tx.id.id,
                               sender: tx.sender!.value,
                               recipient: tx.recipient!.value,
                               amountTokenData: amountTokenData,
                               feeTokenData: feeTokenData,
                               status: status,
                               type: type,
                               created: tx.createdDate,
                               updated: tx.updatedDate,
                               submitted: tx.submittedDate,
                               rejected: tx.rejectedDate,
                               processed: tx.processedDate)
    }

    public func isRecoveryTransactionReadyToSubmit() -> Bool {
        return DomainRegistry.recoveryService.isRecoveryTransactionReadyToSubmit()
    }

    public func isRecoveryInProgress() -> Bool {
        return DomainRegistry.recoveryService.isRecoveryInProgress()
    }

    public func cancelRecovery() {
        DomainRegistry.recoveryService.cancelRecovery()
    }

    public func isRecoveryTransactionConnectsAuthenticator(_ id: String) -> Bool {
        return DomainRegistry.recoveryService.isTransactionConnectsAuthenticator(TransactionID(id))
    }

    public func resumeRecovery(subscriber: EventSubscriber,
                               onError errorHandler: @escaping (Error) -> Void) {
        withEnvironment(for: subscriber, errorHandler: errorHandler) {
            ApplicationServiceRegistry.eventRelay.subscribe(subscriber, for: WalletRecovered.self)
            ApplicationServiceRegistry.eventRelay.subscribe(subscriber, for: RecoveryTransactionHashIsKnown.self)
            DomainRegistry.recoveryService.resume()
        }
    }

    // MARK: - Execution environment setup

    private func withEnvironment(for subscriber: EventSubscriber,
                                 errorHandler:  @escaping (Error) -> Void,
                                 closure: () -> Void) {
        setUpEnvironment(for: subscriber, errorHandler: errorHandler)
        closure()
    }

    private func setUpEnvironment(for subscriber: EventSubscriber, errorHandler:  @escaping (Error) -> Void) {
        DomainRegistry.errorStream.removeHandler(self)
        DomainRegistry.errorStream.addHandler(self) { error in
            errorHandler(RecoveryApplicationService.applicationError(from: error))
        }
        ApplicationServiceRegistry.eventRelay.unsubscribe(subscriber)
    }

    // swiftlint:disable:next cyclomatic_complexity
    private static func applicationError(from domainError: Error) -> Error {
        switch domainError {
        case RecoveryServiceError.invalidContractAddress:
            return RecoveryApplicationServiceError.invalidContractAddress
        case RecoveryServiceError.recoveryPhraseInvalid:
            return RecoveryApplicationServiceError.recoveryPhraseInvalid
        case RecoveryServiceError.recoveryAccountsNotFound:
            return RecoveryApplicationServiceError.recoveryAccountsNotFound
        case RecoveryServiceError.unsupportedOwnerCount:
            return RecoveryApplicationServiceError.unsupportedOwnerCount
        case RecoveryServiceError.unsupportedWalletConfiguration:
            return RecoveryApplicationServiceError.unsupportedWalletConfiguration
        case RecoveryServiceError.failedToChangeOwners:
            return RecoveryApplicationServiceError.failedToChangeOwners
        case RecoveryServiceError.failedToChangeConfirmationCount:
            return RecoveryApplicationServiceError.failedToChangeConfirmationCount
        case RecoveryServiceError.failedToCreateValidTransactionData:
            return RecoveryApplicationServiceError.failedToCreateValidTransactionData
        case RecoveryServiceError.walletNotFound:
            return RecoveryApplicationServiceError.walletNotFound
        case RecoveryServiceError.failedToCreateValidTransaction:
            return RecoveryApplicationServiceError.failedToCreateValidTransaction
        case RecoveryServiceError.internalServerError:
            return RecoveryApplicationServiceError.internalServerError
        default:
            return domainError
        }
    }

}
