//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation
@testable import safe

class MockAccount: AccountProtocol {

    var sessionDuration: TimeInterval = 0
    var maxPasswordAttempts = 0
    var blockedPeriodDuration: TimeInterval = 0
    var hasMasterPassword = false
    var isLoggedIn = false
    var isBlocked = false

    var didSavePassword = false
    var didCleanData = false
    var didRequestBiometricActivation = false
    var setMasterPasswordThrows = false
    var masterPassword: String?

    private var biometricActivationCompletion: (() -> Void)?

    var didRequestBiometricAuthentication = false
    var shouldCallBiometricCompletionImmediately = true
    var shouldBiometryAuthenticationSuccess = true
    private var biometricAuthenticationCompletion: ((Bool) -> Void)?

    var didRequestPasswordAuthentication = false
    var shouldAuthenticateWithPassword = false

    var isBiometryAuthenticationAvailable = true
    var isBiometryFaceID = false

    enum Error: Swift.Error {
        case error
    }

    func cleanupAllData() {
        didCleanData = true
    }

    func setMasterPassword(_ password: String) throws {
        if setMasterPasswordThrows {
            throw Error.error
        }
        masterPassword = password
        didSavePassword = true
    }

    func activateBiometricAuthentication(completion: @escaping () -> Void) {
        didRequestBiometricActivation = true
        biometricActivationCompletion = completion
    }

    func finishBiometricActivation() {
        biometricActivationCompletion?()
    }

    func authenticateWithBiometry(completion: @escaping (Bool) -> Void) {
        didRequestBiometricAuthentication = true
        if shouldCallBiometricCompletionImmediately {
            completion(shouldBiometryAuthenticationSuccess)
        } else {
            biometricAuthenticationCompletion = completion
        }
    }

    func completeBiometryAuthentication(success: Bool) {
        biometricAuthenticationCompletion?(success)
    }

    func authenticateWithPassword(_ password: String) -> Bool {
        didRequestPasswordAuthentication = true
        return shouldAuthenticateWithPassword
    }

}
