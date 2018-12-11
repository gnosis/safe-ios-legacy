//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

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

}
