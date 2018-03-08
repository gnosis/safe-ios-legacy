//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation
@testable import safe

class MockAccount: AccountProtocol {

    var hasMasterPassword = false
    var didSavePassword = false
    var didCleanData = false
    var didRequestBiometricActivation = false
    var setMasterPasswordThrows = false
    private var biometricActivationCompletion: (() -> Void)?

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
        didSavePassword = true
    }

    func activateBiometricAuthentication(completion: @escaping () -> Void) {
        didRequestBiometricActivation = true
        biometricActivationCompletion = completion
    }

    func finishBiometricActivation() {
        biometricActivationCompletion?()
    }

}
