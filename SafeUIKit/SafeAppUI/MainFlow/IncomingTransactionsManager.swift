//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

// swiftlint:disable trailing_closure
final class IncomingTransactionsManager {

    private var coordinators = [String: IncomingTransactionFlowCoordinator]()

    func coordinator(for transactionID: String,
                     source: IncomingTransactionFlowCoordinator.TransactionSource,
                     sourceMeta: Any? = nil) -> IncomingTransactionFlowCoordinator {
        if let coordinator = coordinators[transactionID] {
            return coordinator
        }
        let newCoordinator = IncomingTransactionFlowCoordinator(transactionID: transactionID,
                                                                source: source,
                                                                sourceMeta: sourceMeta,
                                                                onBackButton: { [unowned self] in
                                                                    self.releaseCoordinator(by: transactionID)})
        coordinators[transactionID] = newCoordinator
        return newCoordinator
    }

    func releaseCoordinator(by transactionID: String) {
        coordinators.removeValue(forKey: transactionID)
    }

}
