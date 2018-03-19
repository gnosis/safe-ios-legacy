//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class AccountTests: XCTestCase {

    var account: Account!
    let mockUserDefaults = InMemoryUserDefaults()
    let keychain = MockKeychain()
    let biometricService = MockBiometricService()
    let correctPassword = "Password"
    let wrongPassword = "WrongPassword"

    override func setUp() {
        super.setUp()
        createAccount()
    }

    func test_shared_exists() {
        XCTAssertNotNil(Account.shared)
    }

    // MARK: - hasMasterPassword

    func test_hasMasterPassword_whenNoPassword_thenIsFalse() {
        XCTAssertFalse(account.hasMasterPassword)
    }

    func test_hasMasterPassword_whenPasswordWasSet_thenIsTrue() {
        setPassword()
        XCTAssertTrue(account.hasMasterPassword)
    }

    func test_hasMasterPassword_whenDealingWithDifferentInstances_thenResultIsTheSame() {
        setPassword()
        account = Account(userDefaultsService: mockUserDefaults,
                          keychainService: keychain,
                          biometricAuthService: biometricService)
        XCTAssertTrue(account.hasMasterPassword)
    }

    // MARK: - setMasterPassword

    func test_setMasterPassword_whenWasSet_thenUserDefaultsPropertyIsSet() {
        setPassword()
        XCTAssertTrue(mockUserDefaults.bool(for: UserDefaultsKey.masterPasswordWasSet.rawValue) ?? false)
    }

    func test_setMasterPassword_whenWasSet_thenStoresPasswordInKeychain() {
        setPassword()
        XCTAssertEqual(try! keychain.password(), correctPassword)
    }

    func test_setMasterPassword_whenKeychainThrows_thenSettingPasswordThrows() {
        keychain.throwsOnSavePassword = true
        XCTAssertThrowsError(try account.setMasterPassword(correctPassword), "Expected Account Error") { error in
            XCTAssertEqual(error.localizedDescription, AccountError.settingMasterPasswordFailed.localizedDescription)
        }
    }

    // MARK: - cleanupAllData

    func test_cleanupAllData_whenCalled_thenAccountDataIsCleaned() {
        setPassword()
        cleanupAllData()
        XCTAssertFalse(account.hasMasterPassword)
        XCTAssertFalse(mockUserDefaults.bool(for: UserDefaultsKey.masterPasswordWasSet.rawValue) ?? false)
        XCTAssertNil(try! keychain.password())
    }

    // MARK: - activateBiometricAuthentication

    func test_activateBiometricAuthentication_whenInvoked_thenCallsAccountCompletionAfterBiometricActivation() {
        var completionCalled = false
        biometricService.shouldActivateImmediately = false
        account.activateBiometricAuthentication {
            completionCalled = true
        }
        wait()
        XCTAssertFalse(completionCalled)
        biometricService.completeActivation()
        XCTAssertTrue(completionCalled)
    }

    // MARK: - isLoggedIn

    func test_isLoggedIn_whenNoMasterPassword_AlwaysFalse() {
        setPassword()
        cleanupAllData()
        XCTAssertFalse(account.isLoggedIn)
    }

    func test_isLoggedIn_whenPasswordIsSet_thenIsTrue() {
        XCTAssertFalse(account.isLoggedIn)
        setPassword()
        XCTAssertTrue(account.isLoggedIn)
    }

    func test_isLoggedIn_whenSessionIsInactive_thenIsFalse() {
        setupExpiredSession()
        XCTAssertFalse(account.isLoggedIn)
    }

    // MARK: - authenticateWithPassword

    func test_authenticateWithPassword_whenNoPasswordWasSet_thenReturnsFalse() {
        XCTAssertFalse(account.authenticateWithPassword(correctPassword))
    }

    func test_authenticateWithPassword_whenPasswordIsWrong_thenReturnsFalse() {
        setPassword()
        XCTAssertFalse(account.authenticateWithPassword(wrongPassword))
    }

    func test_authenticateWithPassword_whenPasswordCorrect_thenSuccess() {
        setPassword()
        XCTAssertTrue(account.authenticateWithPassword(correctPassword))
    }

    func test_authenticateWithPassword_whenKeychainThrows_thenFailure() {
        keychain.throwsOnGetPassword = true
        XCTAssertFalse(account.authenticateWithPassword(correctPassword))
    }

    func test_authenticateWithPassword_whenSuccess_thenStartsSession() {
        setupExpiredSession()
        _ = account.authenticateWithPassword(correctPassword)
        XCTAssertTrue(account.isLoggedIn)
    }

    func test_authenticateWithPassword_whenFails_thenStaysLoggedOut() {
        setupExpiredSession()
        _ = account.authenticateWithPassword(wrongPassword)
        XCTAssertFalse(account.isLoggedIn)
    }

    func test_authenticateWithPassword_whenFails_thenIncreasesStoredAttemptCount() {
        mockUserDefaults.setInt(0, for: UserDefaultsKey.passwordAttemptCount.rawValue)
        setupExpiredSession(maxPasswordAttempts: 1)
        _ = account.authenticateWithPassword(wrongPassword)
        XCTAssertEqual(mockUserDefaults.int(for: UserDefaultsKey.passwordAttemptCount.rawValue), 1)
    }

    func test_authenticateWithPassword_whenSuccess_thenResetsStoredAttemptCount() {
        mockUserDefaults.setInt(1, for: UserDefaultsKey.passwordAttemptCount.rawValue)
        setupExpiredSession(maxPasswordAttempts: 1)
        _ = account.authenticateWithPassword(correctPassword)
        XCTAssertEqual(mockUserDefaults.int(for: UserDefaultsKey.passwordAttemptCount.rawValue), 0)
    }

    // MARK: - authenticateWithBiometry

    func test_authenticateWithBiometry_whenInvoked_thenCallsCompletion() {
        var completionCalled = false
        biometricService.shouldAuthenticateImmediately = false
        account.authenticateWithBiometry { _ in
            completionCalled = true
        }
        wait()
        XCTAssertFalse(completionCalled)
        let anyResult = true
        biometricService.completeAuthentication(result: anyResult)
        XCTAssertTrue(completionCalled)
    }

    func test_authenticateWithBiometry_whenFails_thenLoggedOut() {
        setupExpiredSession()
        biometricService.shouldAuthenticateImmediately = true
        biometricService.biometryAuthenticationResult = false
        account.authenticateWithBiometry { _ in }
        XCTAssertFalse(account.isLoggedIn)
    }

    func test_authenticateWithBiometry_whenSuccess_thenStartsSession() {
        setupExpiredSession()
        biometricService.shouldAuthenticateImmediately = true
        biometricService.biometryAuthenticationResult = true
        account.authenticateWithBiometry { _ in }
        XCTAssertTrue(account.isLoggedIn)
    }

    // MARK: - isBiometryAuthenticationAvailable

    func test_isBiometryAuthenticationAvailable_whenAvailable_thenTrue() {
        biometricService.isAuthenticationAvailable = true
        XCTAssertTrue(account.isBiometryAuthenticationAvailable)
    }

    func test_isBiometryFaceID_whenAvailable_thenTrue() {
        biometricService.biometryType = .faceID
        XCTAssertTrue(account.isBiometryFaceID)
    }

    // MARK: - isBlocked

    func test_isBlocked_whenMaxAttemptsReached_thenTrue() {
        createAccount(maxPasswordAttempts: 3)
        setPassword()
        XCTAssertFalse(account.isBlocked)
        _ = account.authenticateWithPassword(wrongPassword)
        XCTAssertFalse(account.isBlocked)
        _ = account.authenticateWithPassword(wrongPassword)
        XCTAssertFalse(account.isBlocked)
        _ = account.authenticateWithPassword(wrongPassword)
        XCTAssertTrue(account.isBlocked)
    }

    func test_isBlocked_whenCreatedAndUserDefaultsReachedMaxAttempts_thenTrue() {
        mockUserDefaults.setInt(1, for: UserDefaultsKey.passwordAttemptCount.rawValue)
        createAccount(maxPasswordAttempts: 1)
        XCTAssertTrue(account.isBlocked)
    }

    func test_isBlocked_whenNotReachedMaxAttempts_thenFalse() {
        createAccount(maxPasswordAttempts: 2)
        setPassword()
        _ = account.authenticateWithPassword(wrongPassword)
        XCTAssertFalse(account.isBlocked)
    }

    func test_isBlocked_whenBecameBlocked_thenStaysBlockedInAnotherInstance() {
        createAccount(maxPasswordAttempts: 1)
        setPassword()
        _ = account.authenticateWithPassword(wrongPassword)
        createAccount(maxPasswordAttempts: 1)
        XCTAssertTrue(account.isBlocked)
    }

    func test_isBlocked_whenBiometryFails_thenItIsNotCountedTowardsPasswordAttempts() {
        createAccount(maxPasswordAttempts: 1)
        setPassword()
        setupExpiredSession()
        biometricService.shouldAuthenticateImmediately = true
        biometricService.biometryAuthenticationResult = false
        account.authenticateWithBiometry { _ in }
        XCTAssertFalse(account.isBlocked)
        _ = account.authenticateWithPassword(wrongPassword)
        XCTAssertTrue(account.isBlocked)
    }

    // MARK: - resetAll

    func test_resetAll_resetsUserDefaults() {
        mockUserDefaults.setInt(1, for: UserDefaultsKey.passwordAttemptCount.rawValue)
        mockUserDefaults.setBool(true, for: UserDefaultsKey.masterPasswordWasSet.rawValue)
        account.resetAll()
        XCTAssertNil(mockUserDefaults.bool(for: UserDefaultsKey.masterPasswordWasSet.rawValue))
        XCTAssertNil(mockUserDefaults.int(for: UserDefaultsKey.passwordAttemptCount.rawValue))
    }

    func test_resetAll_resetsKeychain() {
        setPassword()
        account.resetAll()
        XCTAssertNil(try! keychain.password())
    }

    // MARK: - sessionDuration

    func test_sessionDuration_whenChanged_thenChanged() {
        account.sessionDuration = 1.0
        XCTAssertEqual(account.session.duration, 1.0)
    }

}

// MARK: - Helpers

extension AccountTests {

    private func createAccount(maxPasswordAttempts: Int = 1) {
        account = Account(userDefaultsService: mockUserDefaults,
                          keychainService: keychain,
                          biometricAuthService: biometricService,
                          maxPasswordAttempts: maxPasswordAttempts)
    }

    private func setupExpiredSession(maxPasswordAttempts: Int = 1) {
        let sessionDuration: TimeInterval = 10
        let mockClockService = MockClockService()
        account = Account(userDefaultsService: mockUserDefaults,
                          keychainService: keychain,
                          biometricAuthService: biometricService,
                          systemClock: mockClockService,
                          sessionDuration: sessionDuration,
                          maxPasswordAttempts: maxPasswordAttempts)
        setPassword()
        mockClockService.currentTime += sessionDuration
    }

    private func setPassword() {
        XCTAssertNoThrow(try account.setMasterPassword(correctPassword))
    }

    private func cleanupAllData() {
        XCTAssertNoThrow(try account.cleanupAllData())
    }

}

class InMemoryUserDefaults: UserDefaultsServiceProtocol {

    var dict = [String: Any]()

    func bool(for key: String) -> Bool? {
        return dict[key] as? Bool
    }

    func setBool(_ value: Bool, for key: String) {
        dict[key] = value
    }

    func int(for key: String) -> Int? {
        return dict[key] as? Int
    }

    func setInt(_ value: Int, for key: String) {
        dict[key] = value
    }

    func deleteKey(_ key: String) {
        dict.removeValue(forKey: key)
    }

}

class MockKeychain: KeychainServiceProtocol {

    private var storedPassword: String?
    var throwsOnSavePassword = false
    var throwsOnGetPassword = false

    enum Error: Swift.Error {
        case error
    }

    func password() throws -> String? {
        if throwsOnGetPassword {
            throw MockKeychain.Error.error
        }
        return storedPassword
    }

    func savePassword(_ password: String) throws {
        if throwsOnSavePassword {
            throw MockKeychain.Error.error
        }
        storedPassword = password
    }

    func removePassword() throws {
        storedPassword = nil
    }

}

class MockBiometricService: BiometricAuthenticationServiceProtocol {

    var biometryType: BiometryType = .none
    private var savedActivationCompletion: (() -> Void)?
    var shouldActivateImmediately = false
    var biometryAuthenticationResult = true
    var isAuthenticationAvailable = false

    private var savedAuthenticationCompletion: ((Bool) -> Void)?
    var shouldAuthenticateImmediately = false

    func activate(completion: @escaping () -> Void) {
        if shouldActivateImmediately {
            completion()
        } else {
            savedActivationCompletion = completion
        }
    }

    func completeActivation() {
        savedActivationCompletion?()
    }

    func authenticate(completion: @escaping (Bool) -> Void) {
        if shouldAuthenticateImmediately {
            completion(biometryAuthenticationResult)
        } else {
            savedAuthenticationCompletion = completion
        }
    }

    func completeAuthentication(result: Bool) {
        savedAuthenticationCompletion?(result)
    }

}
