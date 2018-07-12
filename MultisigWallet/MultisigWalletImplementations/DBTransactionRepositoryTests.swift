//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletImplementations
import MultisigWalletDomainModel
import Database

class DBTransactionRepositoryTests: XCTestCase {

    func test_all() throws {
        let db = SQLiteDatabase(name: String(reflecting: self),
                                fileManager: FileManager.default,
                                sqlite: CSQLite3(),
                                bundleId: String(reflecting: self))
        try? db.destroy()
        try db.create()
        defer {
            try? db.destroy()
        }

        let repo = DBTransactionRepository(db: db)
        try repo.setUp()

        let walletID = WalletID()
        let accountID = AccountID(token: "ETH")
        let transaction = try Transaction(id: repo.nextID(),
                                          type: .transfer,
                                          walletID: walletID,
                                          accountID: accountID)
            .change(amount: .ether(3))
            .change(fee: .ether(1))
            .change(sender: BlockchainAddress(value: "sender"))
            .change(recipient: BlockchainAddress(value: "recipient"))
            .change(status: .signing)
            .add(signature: Signature(data: Data(repeating: 1, count: 7), address: BlockchainAddress(value: "signer1")))
            .add(signature: Signature(data: Data(repeating: 2, count: 7), address: BlockchainAddress(value: "signer2")))
            .set(hash: TransactionHash("hash"))
            .change(status: .pending)
            .change(status: .success)

        try repo.save(transaction)
        let saved = try repo.findByID(transaction.id)

        XCTAssertEqual(saved, transaction)
        XCTAssertEqual(saved?.type, transaction.type)
        XCTAssertEqual(saved?.walletID, transaction.walletID)
        XCTAssertEqual(saved?.amount, transaction.amount)
        XCTAssertEqual(saved?.fee, transaction.fee)
        XCTAssertEqual(saved?.sender, transaction.sender)
        XCTAssertEqual(saved?.recipient, transaction.recipient)
        XCTAssertEqual(saved?.signatures, transaction.signatures)
        XCTAssertEqual(saved?.transactionHash, transaction.transactionHash)
        XCTAssertEqual(saved?.status, transaction.status)

        try repo.remove(transaction)
        XCTAssertNil(try repo.findByID(transaction.id))
    }

}
