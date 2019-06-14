//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessImplementations
import IdentityAccessDomainModel

class InMemoryUserRepositoryTests: XCTestCase {

    let repository: SingleUserRepository = InMemoryUserRepository()
    var user: User!
    var other: User!

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: MockEncryptionService(), for: EncryptionService.self)
        DomainRegistry.put(service: repository, for: SingleUserRepository.self)
        DomainRegistry.put(service: MockBiometricService(), for: BiometricAuthenticationService.self)
        DomainRegistry.put(service: IdentityService(), for: IdentityService.self)
        do {
            _ = try DomainRegistry.identityService.registerUser(password: "Mypass123")
            user = repository.primaryUser()!
            removePrimaryUser()
            _ = try DomainRegistry.identityService.registerUser(password: "Otherpass123")
            other = repository.primaryUser()
            removePrimaryUser()
        } catch {
            XCTFail("Failed to setUp")
        }
    }

    private func removePrimaryUser() {
        if let user = repository.primaryUser() {
            repository.remove(user)
        }
    }

    func test_save_makesPrimaryUser() {
        repository.save(user)
        let savedUser = repository.primaryUser()
        XCTAssertEqual(savedUser, user)
    }

    func test_nextId_returnsUniqueIdEveryTime() {
        let ids = (0..<500).map { _ -> UserID in repository.nextId() }
        XCTAssertEqual(Set(ids).count, ids.count)
    }

    func test_remove_removesUser() {
        repository.save(user)
        repository.remove(user)
        XCTAssertNil(repository.primaryUser())
    }

    func test_user_whenSearchingWithExactPassword_thenFindsIt() {
        repository.save(user)
        XCTAssertEqual(repository.user(encryptedPassword: user.password), user)
    }

    func test_user_whenSearchingWithWrongPassword_thenNotFound() {
        repository.save(user)
        XCTAssertNil(repository.user(encryptedPassword: user.password + "a"))
    }

}
