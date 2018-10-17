//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import MultisigWalletImplementations
import CommonTestSupport

class TransactionDomainServiceTests: XCTestCase {

    let repo = InMemoryTransactionRepository()
    let service = TransactionDomainService()
    var tx: Transaction!

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: repo, for: TransactionRepository.self)
        tx = Transaction(id: repo.nextID(),
                         type: .transfer,
                         walletID: WalletID(),
                         accountID: AccountID(tokenID: Token.Ether.id, walletID: WalletID()))

    }

    func test_whenRemovingDraft_thenRemoves() {
        repo.save(tx)
        service.removeDraftTransaction(tx.id)
        XCTAssertNil(repo.findByID(tx.id))
    }

    func test_whenStatusIsNotDraft_thenDoesNotRemovesTransaction() {
        tx.change(status: .discarded)
        repo.save(tx)
        service.removeDraftTransaction(tx.id)
        XCTAssertNotNil(repo.findByID(tx.id))
    }

}
