//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import IdentityAccessDomainModel

public class MockBiometricService: BiometricAuthenticationService {

    public var biometryType: BiometryType = .none
    private var savedActivationCompletion: (() -> Void)?
    public var shouldActivateImmediately = false
    public var biometryAuthenticationResult = true
    public var isAuthenticationAvailable = false
    private var savedAuthenticationCompletion: ((Bool) -> Void)?
    public var shouldAuthenticateImmediately = false

    public init() {}

    public func activate(completion: @escaping () -> Void) {
        if shouldActivateImmediately {
            completion()
        } else {
            savedActivationCompletion = completion
        }
    }

    public func completeActivation() {
        savedActivationCompletion?()
    }

    public func authenticate(completion: @escaping (Bool) -> Void) {
        if shouldAuthenticateImmediately {
            completion(biometryAuthenticationResult)
        } else {
            savedAuthenticationCompletion = completion
        }
    }

    public func completeAuthentication(result: Bool) {
        savedAuthenticationCompletion?(result)
    }

}
