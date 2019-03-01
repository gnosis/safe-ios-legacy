//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

open class DisconnectBrowserExtensionDomainService: ReplaceBrowserExtensionDomainService {

    override var transactionType: TransactionType { return .disconnectBrowserExtension }

    override func dummyTransactionData() -> Data {
        if let linkedList = remoteOwnersList(),
            let toDelete = requiredWallet.owner(role: .browserExtension)?.address,
            linkedList.contains(toDelete) {
            let data = contractProxy.removeOwner(prevOwner: linkedList.addressBefore(toDelete),
                                                 owner: toDelete,
                                                 newThreshold: 1)
            return data
        }
        var remoteList = OwnerLinkedList()
        remoteList.add(.zero)
        return contractProxy.removeOwner(prevOwner: remoteList.addressBefore(.one),
                                         owner: .zero,
                                         newThreshold: 1)
    }

    public func update(transaction: TransactionID) {
        let tx = self.transaction(transaction)
        if tx.status == .signing {
            tx.stepBack()
        }
        tx.change(data: realTransactionData())
        repository.save(tx)
    }

    public func realTransactionData() -> Data? {
        let extensionAddress = requiredWallet.owner(role: .browserExtension)!.address
        guard let linkedList = remoteOwnersList(), linkedList.contains(extensionAddress) else { return nil }
        return contractProxy.removeOwner(prevOwner: linkedList.addressBefore(extensionAddress),
                                         owner: extensionAddress,
                                         newThreshold: 1)
    }

    open override func postProcess(transactionID: TransactionID) throws {
        guard let tx = repository.findByID(transactionID),
            tx.type == transactionType,
            tx.status == .success || tx.status == .failed,
            let wallet = DomainRegistry.walletRepository.findByID(tx.walletID) else { return }
        if tx.status == .success {
            try removeOldOwner(from: wallet)
            wallet.changeConfirmationCount(1)
            DomainRegistry.walletRepository.save(wallet)
        }
        unregisterPostProcessing(for: transactionID)
    }

}
