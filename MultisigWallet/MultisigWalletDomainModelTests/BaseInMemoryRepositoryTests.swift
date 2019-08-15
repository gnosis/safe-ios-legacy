//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import Common

class BaseInMemoryRepositoryTests: XCTestCase {

    class TestEntity: IdentifiableEntity<String> {}

    var item = TestEntity(id: "id")
    var repository = BaseInMemoryRepository<TestEntity, String>()

    func test_save_whenSaving_thenCanFindByID() {
        repository.save(item)
        XCTAssertEqual(repository.find(id: item.id), item)
    }

    func test_remove_whenRemoved_thenCannotFindIt() {
        repository.save(item)
        repository.remove(item)
        XCTAssertNil(repository.find(id: item.id))
    }

}
