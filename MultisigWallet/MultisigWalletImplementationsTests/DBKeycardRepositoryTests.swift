//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletImplementations
import MultisigWalletDomainModel
import Database

class DBKeycardRepositoryTests: XCTestCase {

    func test_all() throws {
        let db = SQLiteDatabase(name: String(reflecting: self),
                                fileManager: FileManager.default,
                                sqlite: CSQLite3(),
                                bundleId: String(reflecting: self))
        try? db.destroy()
        try db.create()
        defer { try? db.destroy() }

        let repo = DBKeycardRepository(db: db)
        repo.setUp()

        // pairing

        let instanceUID = Data([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15])
        XCTAssertNil(repo.findPairing(instanceUID: instanceUID))

        let pairing = KeycardPairing(instanceUID: instanceUID, index: 0, key: Data([0, 1, 2, 3, 4]))

        repo.save(pairing)
        XCTAssertEqual(repo.findPairing(instanceUID: instanceUID), pairing)
        XCTAssertNil(repo.findPairing(instanceUID: Data([1, 2, 3])))

        repo.remove(pairing)
        XCTAssertNil(repo.findPairing(instanceUID: instanceUID))

        // key

        let address = Address.testAccount1
        XCTAssertNil(repo.findKey(with: address))

        let key = KeycardKey(address: address,
                             instanceUID: instanceUID,
                             masterKeyUID: Data([1, 2, 3, 4]),
                             keyPath: "m/44'/0'",
                             publicKey: Data([5, 6, 7, 8]))

        repo.save(key)
        XCTAssertEqual(repo.findKey(with: address), key)
        XCTAssertNil(repo.findKey(with: .testAccount2))

        repo.remove(key)
        XCTAssertNil(repo.findKey(with: address))
    }

}
