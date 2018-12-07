//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import Database
import CommonImplementations

public class DBWalletRepository: DBEntityRepository<Wallet, WalletID>, WalletRepository {

    public override var table: TableSchema {
        return .init("tbl_wallets",
                     "id TEXT NOT NULL PRIMARY KEY",
                     "state INTEGER NOT NULL",
                     "owners TEXT NOT NULL",
                     "address TEXT",
                     "minimum_deployment_tx_amount TEXT",
                     "creation_tx_hash TEXT",
                     "confirmation_count INTEGER NOT NULL")
    }

    public override func insertionBindings(_ object: Wallet) -> [SQLBindable?] {
        return bindable([object.id,
                         object.state,
                         object.owners,
                         object.address,
                         object.minimumDeploymentTransactionAmount]) +
            [object.creationTransactionHash,
             object.confirmationCount]
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
                            minimumDeploymentTransactionAmount: minimumDeploymentAmount,
                            creationTransactionHash: rs["creation_tx_hash"],
                            confirmationCount: confirmationCount)
        return wallet
    }

    public func findByID(_ walletID: WalletID) -> Wallet? {
        return find(id: walletID)
    }

}
