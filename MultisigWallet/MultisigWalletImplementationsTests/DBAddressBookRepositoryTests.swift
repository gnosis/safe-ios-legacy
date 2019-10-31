//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletImplementations
import MultisigWalletDomainModel
import Database

class DBAddressBookRepositoryTests: XCTestCase {

    var db: SQLiteDatabase!
    var repo: DBAddressBookRepository!

    override func setUp() {
        super.setUp()
        db = SQLiteDatabase(name: String(reflecting: self),
                            fileManager: FileManager.default,
                            sqlite: CSQLite3(),
                            bundleId: String(reflecting: self))
        try? db.destroy()
        try! db.create()
        repo = DBAddressBookRepository(db: db)
        repo.setUp()
    }

    override func tearDown() {
        super.tearDown()
        try? db.destroy()
    }

    func test_All() throws {
        let entry1 = AddressBookEntry(name: "Test Account 1", address: Address.testAccount1.value, type: .regular)
        repo.save(entry1)
        let saved = repo.find(id: entry1.id)
        XCTAssertEqual(saved, entry1)

        let entry2 = AddressBookEntry(name: "Test Account 2", address: Address.testAccount2.value, type: .wallet)
        let entry0 = AddressBookEntry(name: "Test Account 0", address: Address.testAccount2.value, type: .regular)
        repo.save(entry2)
        repo.save(entry0)

        let foundByAddress = repo.find(address: Address.testAccount2.value, types: [.regular, .wallet])
        XCTAssertEqual(foundByAddress.count, 2)
        XCTAssertEqual(foundByAddress[0], entry0)
        XCTAssertEqual(foundByAddress[1], entry2)
        let foundByAddress1 = repo.find(address: Address.testAccount2.value, types: [.regular])
        XCTAssertEqual(foundByAddress1.count, 1)
        XCTAssertEqual(foundByAddress1[0], entry0)

        let all = repo.all()
        XCTAssertEqual(all.count, 3)
        XCTAssertEqual(all[0], entry0)
        XCTAssertEqual(all[1], entry1)
        XCTAssertEqual(all[2], entry2)

        repo.remove(entry1)
        XCTAssertTrue(repo.find(address: entry1.address, types: [.regular, .wallet]).isEmpty)
        XCTAssertNil(repo.find(id: entry1.id))
        XCTAssertEqual(repo.all().count, 2)
    }

}
