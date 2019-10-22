//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

open class DisconnectTwoFADomainService: ReplaceTwoFADomainService {

    override var postProcessTypes: [TransactionType] {
        return [.disconnectAuthenticator, .disconnectStatusKeycard]
    }

    public override func createTransaction() -> TransactionID {
        let txID = super.createTransaction()
        updateTransaction(txID, with: transactionTypeFromWalletOwner())
        return txID
    }

    private func transactionTypeFromWalletOwner() -> TransactionType {
        if wallet?.owner(role: .browserExtension) != nil {
            return .disconnectAuthenticator
        } else if wallet?.owner(role: .keycard) != nil {
            return .disconnectStatusKeycard
        }
        return .disconnectAuthenticator
    }

    override func dummyTransactionData() -> Data {
        if let linkedList = remoteOwnersList(),
            let toDelete = wallet?.twoFAOwner?.address,
            linkedList.contains(toDelete) {
            let data = contractProxy.removeOwner(prevOwner: linkedList.addressBefore(toDelete),
                                                 owner: toDelete,
                                                 newThreshold: 1)
            return data
        }
        var remoteList = OwnerLinkedList()
        remoteList.add(.zero)
        return contractProxy.removeOwner(prevOwner: remoteList.addressBefore(.zero),
                                         owner: .zero,
                                         newThreshold: 1)
    }

    public func update(transaction: TransactionID) {
        stepBackToDraft(transaction)
        let tx = self.transaction(transaction)
        tx.change(data: realTransactionData())
        repository.save(tx)
    }

    public func realTransactionData() -> Data? {
        guard let address = wallet?.twoFAOwner?.address,
            let linkedList = remoteOwnersList(),
            linkedList.contains(address) else { return nil }
        return contractProxy.removeOwner(prevOwner: linkedList.addressBefore(address),
                                         owner: address,
                                         newThreshold: 1)
    }

    open override func postProcess(transactionID: TransactionID) throws {
        guard let tx = repository.find(id: transactionID),
        postProcessTypes.contains(tx.type),
            tx.status == .success || tx.status == .failed,
            let wallet = DomainRegistry.walletRepository.find(id: tx.accountID.walletID) else { return }
        if tx.status == .success {
            try removeOldTwoFAOwner(from: wallet)
            wallet.changeConfirmationCount(1)
            DomainRegistry.walletRepository.save(wallet)
        }
        unregisterPostProcessing(for: transactionID)
    }

}
