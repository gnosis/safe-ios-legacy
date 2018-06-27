//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletImplementations
import Common

class BaseInMemoryRepositoryTests: XCTestCase {

    class TestEntity: IdentifiableEntity<String> {}

    var item = TestEntity(id: "id")
    var repository = BaseInMemoryRepository<TestEntity, String>()

    func test_save_whenSaving_thenCanFindByID() throws {
        try repository.save(item)
        XCTAssertEqual(try repository.findByID(item.id), item)
    }

    func test_remove_whenRemoved_thenCannotFindIt() throws {
        try repository.save(item)
        try repository.remove(item)
        XCTAssertNil(try repository.findByID(item.id))
    }

}
