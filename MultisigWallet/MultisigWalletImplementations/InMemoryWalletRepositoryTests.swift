//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletImplementations
import MultisigWalletDomainModel

class InMemoryWalletRepositoryTests: XCTestCase {

    var wallet: Wallet!
    var repository: InMemoryWalletRepository!

    override func setUp() {
        super.setUp()
        let owner = Wallet.createOwner(address: "address")
        XCTAssertNoThrow(wallet = try Wallet(id: try WalletID(), owner: owner, kind: "kind"))
        repository = InMemoryWalletRepository()
    }

    func test_save_whenSaving_thenCanFindByID() throws {
        try repository.save(wallet)
        XCTAssertEqual(try repository.findByID(wallet.id), wallet)
    }

    func test_remove_whenRemoved_thenCannotFindIt() throws {
        try repository.save(wallet)
        try repository.remove(wallet)
        XCTAssertNil(try repository.findByID(wallet.id))
    }

}
