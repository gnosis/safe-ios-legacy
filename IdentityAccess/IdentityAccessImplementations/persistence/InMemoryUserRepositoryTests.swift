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
        DomainRegistry.put(service: MockEncryptionService(), for: EncryptionServiceProtocol.self)
        DomainRegistry.put(service: repository, for: UserRepository.self)
        DomainRegistry.put(service: MockBiometricService(), for: BiometricAuthenticationService.self)
        DomainRegistry.put(service: IdentityService(), for: IdentityService.self)
        do {
            user = try DomainRegistry.identityService.registerUser(password: "Mypass123")
            try repository.remove(user)
            other = try DomainRegistry.identityService.registerUser(password: "Otherpass123")
            try repository.remove(other)
        } catch {
            XCTFail("Failed to setUp")
        }
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

    func test_user_whenSearchingWithExactPassword_thenFindsIt() throws {
        try repository.save(user)
        XCTAssertEqual(repository.user(encryptedPassword: user.password), user)
    }

    func test_user_whenSearchingWithWrongPassword_thenNotFound() throws {
        try repository.save(user)
        XCTAssertNil(repository.user(encryptedPassword: user.password + "a"))
    }

}
