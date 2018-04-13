//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessImplementations
import IdentityAccessDomainModel

class InMemoryUserRepositoryTests: XCTestCase {

    let repository: UserRepository = InMemoryUserRepository()
    var user: User!
    var other: User!

    override func setUp() {
        super.setUp()
        user = User(id: repository.nextId(), password: "pass")
        other = User(id: repository.nextId(), password: "")
    }

    func test_save_makesPrimaryUser() throws {
        try repository.save(user)
        let savedUser = repository.primaryUser()
        XCTAssertEqual(savedUser, user)
    }

    func test_save_whenAlreadySavedUser_onlyAllowsModificationsOnSave() throws {
        try repository.save(user)
        XCTAssertThrowsError(try repository.save(other)) { error in
            XCTAssertEqual(error as? InMemoryUserRepository.Error, .primaryUserAlreadyExists)
        }
    }

    func test_nextId_returnsUniqueIdEveryTime() {
        let ids = (0..<500).map { _ -> UserID in repository.nextId() }
        XCTAssertEqual(Set(ids).count, ids.count)
    }

    func test_remove_removesUser() throws {
        try repository.save(user)
        try repository.remove(user)
        XCTAssertNil(repository.primaryUser())
    }

    func test_remove_whenRemovingDifferentUser_throwsError() throws {
        try repository.save(user)
        XCTAssertThrowsError(try repository.remove(other)) { error in
            XCTAssertEqual(error as? InMemoryUserRepository.Error, .userNotFound)
        }
    }

}
