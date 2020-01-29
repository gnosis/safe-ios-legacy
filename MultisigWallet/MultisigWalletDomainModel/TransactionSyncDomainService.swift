//
//  Copyright © 2020 Gnosis Ltd. All rights reserved.
//

import Foundation

// The service for importing transactions from the transaction service into repositories.
public class TransactionSyncDomainService {

// The service will get all transactions from remote services, and all transactions that exist in the model.
//
// Then, it will merge transactions, enhancing local model with remote data and updating local transaction
// status information based on the remote status. (The source of truth is the remote).
    func sync(walletID: WalletID) {
        guard let wallet = DomainRegistry.walletRepository.find(id: walletID),
            wallet.isReadyToUse,
            let safeAddress = wallet.address else { return }

        let remoteTransactions = DomainRegistry.safeTransactionService.transactions(safe: safeAddress)
            .compactMap { (tx) -> Transaction? in
                tx.identifyingHash == nil ? nil : tx
            }.sorted { (a, b) -> Bool in
                a.identifyingHash!.toHexString() < b.identifyingHash!.toHexString()
            }
        var localTransactions = DomainRegistry.transactionRepository.find(wallet: wallet.id)
            .compactMap { (tx) -> Transaction? in
                tx.identifyingHash == nil ? nil : tx
            }.sorted { (a, b) -> Bool in
                a.identifyingHash!.toHexString() < b.identifyingHash!.toHexString()
            }
        // for all remote tx-es that exist in local

        for local in localTransactions {
            if let remote = remoteTransactions.first(where: { local.identifyingHash! == $0.identifyingHash! }) {
                //    update set(hash) from txHash
                if let txHash = remote.transactionHash, local.transactionHash != remote.transactionHash {
                    local.set(hash: txHash)
                }

                if local.status != remote.status {
                    //    update status
                    local.change(status: remote.status)

                    // update dates
                    if let date = remote.createdDate {
                        local.timestampCreated(at: date)
                    }

                    if let date = remote.updatedDate {
                        local.timestampUpdated(at: date)
                    }

                    if let date = remote.rejectedDate {
                        local.timestampRejected(at: date)
                    }

                    if let date = remote.processedDate {
                        local.timestampProcessed(at: date)
                    }

                    if let date = remote.submittedDate {
                        local.timestampSubmitted(at: date)
                    }

                }

                //    update confirmations (remove local sigs, add remote sigs)
                for signature in local.signatures {
                    local.remove(signature: signature)
                }
                for signature in remote.signatures {
                    local.add(signature: signature)
                }

            }

        }

        // add all remote tx-es that do not exist in local
        let localHashes = localTransactions.map { $0.identifyingHash! }
        let newTxes = remoteTransactions.filter { !localHashes.contains($0.identifyingHash!) }
        localTransactions.append(contentsOf: newTxes)

        // save it all
        for tx in localTransactions {
            DomainRegistry.transactionRepository.save(tx)
        }
    }
}
