//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

open class DisconnectTwoFADomainService: ReplaceTwoFADomainService {

    private var _transactionType: TransactionType = .disconnectAuthenticator

    override var transactionType: TransactionType { return _transactionType }

    override var postProcessTypes: [TransactionType] {
        return [.disconnectAuthenticator, .disconnectStatusKeycard]
    }

    public override func updateTransactionType() -> TransactionType {
        if wallet?.owner(role: .browserExtension) != nil {
            _transactionType = .disconnectAuthenticator
        } else if wallet?.owner(role: .keycard) != nil {
            _transactionType = .disconnectStatusKeycard
        }
        return _transactionType
    }

    override func dummyTransactionData() -> Data {
        let ownerToDelete = wallet?.owner(role: .browserExtension) ?? wallet?.owner(role: .keycard)
        if let linkedList = remoteOwnersList(),
            let toDelete = ownerToDelete?.address,
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
        let ownerToDelete = wallet?.owner(role: .browserExtension) ?? wallet?.owner(role: .keycard)
        guard let address = ownerToDelete?.address,
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
