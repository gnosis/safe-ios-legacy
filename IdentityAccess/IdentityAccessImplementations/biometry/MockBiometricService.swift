//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import IdentityAccessDomainModel

/// Mock biometric service for testing purposes.
public class MockBiometricService: BiometricAuthenticationService {

    public var biometryType: BiometryType = .none
    private var savedActivationCompletion: (() -> Void)?
    public var shouldActivateImmediately = false
    public var biometryAuthenticationResult = true
    public var isAuthenticationAvailable = false
    private var savedAuthenticationCompletion: ((Bool) -> Void)?
    public var shouldAuthenticateImmediately = false

    public var didActivate = false
    private var shouldAuthenticate = false

    public func allowAuthentication() {
        shouldAuthenticate = true
    }

    public func prohibitAuthentication() {
        shouldAuthenticate = false
    }

    public init() {}

    public func activate(completion: @escaping () -> Void) {
        try? activate()
        if shouldActivateImmediately {
            completion()
        } else {
            savedActivationCompletion = completion
        }
    }

    public func activate() throws {
        didActivate = true
    }

    public func authenticate() -> Bool {
        return shouldAuthenticate
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
