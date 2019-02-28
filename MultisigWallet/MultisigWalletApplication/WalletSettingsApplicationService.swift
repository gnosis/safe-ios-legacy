//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import Common

open class WalletSettingsApplicationService {

    public init() {}

    public func createRecoveryPhraseTransaction() -> TransactionData {
        let transactionID = DomainRegistry.settingsService.createReplaceRecoveryPhraseTransaction()
        DomainRegistry.settingsService.estimateRecoveryPhraseTransaction(transactionID)
        let tx = DomainRegistry.transactionRepository.find(id: transactionID)!
        return ApplicationServiceRegistry.recoveryService.transactionData(tx)
    }

    public func removeTransaction(_ id: String) {
        if let tx = DomainRegistry.transactionRepository.find(id: TransactionID(id)) {
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

    public func resyncWithBrowserExtension() throws {
        guard let wallet = DomainRegistry.walletRepository.selectedWallet() else { return }
        try DomainRegistry.communicationService.notifyWalletCreated(walletID: wallet.id)
    }

}
