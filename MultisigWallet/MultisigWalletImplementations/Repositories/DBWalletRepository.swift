//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import Database
import CommonImplementations

public class DBWalletRepository: DBEntityRepository<Wallet, WalletID>, WalletRepository {

    public override var table: TableSchema {
        // IMPORTANT: If you are adding new field to the SQL table, then add it to the end of the list.
        // In existing app deployments, the order of fields in existing tables will not change just because
        // the order of fields below is changed. If you _really_ want to change the order of the columns,
        // then you have to make a migration by adding new table, moving data to the new table,
        // removing the old table, and renaming the new table to old table name.
        return .init("tbl_wallets",
                     "id TEXT NOT NULL PRIMARY KEY",
                     "state INTEGER NOT NULL",
                     "owners TEXT NOT NULL",
                     "address TEXT",
                     "minimum_deployment_tx_amount TEXT",
                     "creation_tx_hash TEXT",
                     "confirmation_count INTEGER NOT NULL",
                     "fee_payment_token_address TEXT",
                     "master_copy_address TEXT",
                     "contract_version TEXT")
    }

    public override func insertionBindings(_ object: Wallet) -> [SQLBindable?] {
        return bindable([object.id,
                         object.state,
                         object.owners,
                         object.address,
                         object.minimumDeploymentTransactionAmount,
                         object.creationTransactionHash,
                         object.confirmationCount,
                         object.feePaymentTokenAddress,
                         object.masterCopyAddress,
                         object.contractVersion])
    }

    public override func objectFromResultSet(_ rs: ResultSet) -> Wallet? {
        guard let id: String = rs["id"],
            let stateRawValue: Int = rs["state"],
            let state = WalletState.State(rawValue: stateRawValue),
            let ownersString: String = rs["owners"],
            let confirmationCount: Int = rs["confirmation_count"] else { return nil }
        let minimumDeploymentAmount = TokenInt(serializedValue: rs["minimum_deployment_tx_amount"])
        let wallet = Wallet(id: WalletID(id),
                            state: state,
                            owners: OwnerList(serializedValue: ownersString),
                            address: Address(serializedValue: rs["address"]),
                            feePaymentTokenAddress: Address(serializedValue: rs["fee_payment_token_address"]),
                            minimumDeploymentTransactionAmount: minimumDeploymentAmount,
                            creationTransactionHash: rs["creation_tx_hash"],
                            confirmationCount: confirmationCount,
                            masterCopyAddress: Address(serializedValue: rs["master_copy_address"]),
                            contractVersion: rs["contract_version"])
        return wallet
    }

    public func findByID(_ walletID: WalletID) -> Wallet? {
        return find(id: walletID)
    }

}
