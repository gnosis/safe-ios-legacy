//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletImplementations
import MultisigWalletDomainModel
import Database

class BaseTokenListItemRepositoryTests: XCTestCase {

    var repository: TokenListItemRepository!

    func do_test_Find_Remove_All_Save() {
        let eth = Token.Ether
        let item = TokenListItem(token: eth, status: .whitelisted, canPayTransactionFee: false)
        repository.save(item)
        XCTAssertEqual(repository.find(id: eth.id), item)
        XCTAssertEqual(repository.all().count, 1)
        let item2 = TokenListItem(token: Token.gno, status: .regular, canPayTransactionFee: false)
        repository.save(item2)
        let all = repository.all()
        XCTAssertEqual(all.count, 2)
        XCTAssertEqual(all[0].token, eth)
        XCTAssertEqual(all[0].status, .whitelisted)
        XCTAssertEqual(all[1].token, Token.gno)
        XCTAssertEqual(all[1].status, .regular)
        repository.remove(item)
        XCTAssertNotNil(repository.find(id: eth.id))
        XCTAssertEqual(repository.all().count, 1)
    }

    func do_test_whenSavingWhitelistedItem_thenAssignsProperSortingOrder() {
        let gno = TokenListItem(token: Token.gno, status: .whitelisted, canPayTransactionFee: false)
        let rdn = TokenListItem(token: Token.rdn, status: .regular, canPayTransactionFee: false)
        let mgn = TokenListItem(token: Token.mgn, status: .whitelisted, canPayTransactionFee: false)
        repository.save(gno)
        repository.save(rdn)
        repository.save(mgn)

        // Correct assignment of new sorting ids for new whitelisted tokens
        let savedGNO = repository.find(id: Token.gno.id)!
        XCTAssertEqual(savedGNO.sortingId, 0)
        let savedRDN = repository.find(id: Token.rdn.id)!
        XCTAssertEqual(savedRDN.sortingId, nil)
        let savedMGN = repository.find(id: Token.mgn.id)!
        XCTAssertEqual(savedMGN.sortingId, 1)

        // Updating whitelisted token should not influence its sorting id
        repository.save(savedGNO)
        let savedGNO_1 = repository.find(id: Token.gno.id)!
        XCTAssertEqual(savedGNO_1.sortingId, 0)

        // Updating status of whitelisted token should remove its sorting id
        let blacklistedGNO = TokenListItem(token: Token.gno, status: .blacklisted, canPayTransactionFee: false)
        repository.save(blacklistedGNO)
        let savedGNO_2 = repository.find(id: Token.gno.id)!
        XCTAssertEqual(savedGNO_2.sortingId, nil)

        // New whitelisted token takes next available sorting id
        let whitelistedRDN = TokenListItem(token: Token.rdn, status: .whitelisted, canPayTransactionFee: false)
        repository.save(whitelistedRDN)
        let savedRDN_2 = repository.find(id: Token.rdn.id)!
        XCTAssertEqual(savedRDN_2.sortingId, 2)

        // Whitelisted tokens should be returned sorted by sorting id
        let whitelistedTokens = repository.whitelisted()
        XCTAssertEqual(whitelistedTokens.count, 2)
        XCTAssertTrue(whitelistedTokens[0].sortingId! < whitelistedTokens[1].sortingId!)
    }

}


class InMemoryTokenListItemRepositoryTests: BaseTokenListItemRepositoryTests {

    override func setUp() {
        super.setUp()
        repository = InMemoryTokenListItemRepository()
    }

    func test_Find_Remove_All_Save() {
        do_test_Find_Remove_All_Save()
    }

    func test_whenSavingWhitelistedItem_thenAssignsProperSortingOrder() {
        do_test_whenSavingWhitelistedItem_thenAssignsProperSortingOrder()
    }

}

class DBTokenListItemRepositoryTests: BaseTokenListItemRepositoryTests {

    var db: Database!

    override func setUp() {
        super.setUp()
        db = SQLiteDatabase(name: String(reflecting: self),
                            fileManager: FileManager.default,
                            sqlite: CSQLite3(),
                            bundleId: String(reflecting: self))
        try? db.destroy()
        try! db.create()

        let repository = DBTokenListItemRepository(db: db)
        repository.setUp()
        self.repository = repository
    }

    override func tearDown() {
        super.tearDown()
        try? db.destroy()
    }


    func test_Find_Remove_All_Save() {
        do_test_Find_Remove_All_Save()
    }

    func test_whenSavingWhitelistedItem_thenAssignsProperSortingOrder() {
        do_test_whenSavingWhitelistedItem_thenAssignsProperSortingOrder()
    }

}
