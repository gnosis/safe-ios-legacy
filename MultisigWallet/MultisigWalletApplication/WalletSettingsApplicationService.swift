//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

open class WalletSettingsApplicationService {

    public init() {}

    open func createRecoveryPhraseTransaction() -> TransactionData {
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
