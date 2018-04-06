//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

// user registered when password is set on account
// authentication sets session to active // or creates active session
// when session expires, authentication invalidates
//precondition(authenticationService.isUserRegistered() || !authenticationService.isUserAuthenticated(),
//             "User cannot be unregistered and authenticated at the same time")

class MockAuthenticationService: AuthenticationApplicationService {

    private var userRegistered = false
    private var userAuthenticated = false
    private var authenticationAllowed = false

    init() {
        super.init(account: MockAccount())
    }

    func unregisterUser() {
        userRegistered = false
    }

    override func isUserRegistered() -> Bool {
        return userRegistered
    }

    override func registerUser(password: String, completion: (() -> Void)? = nil) throws {
        userRegistered = true
        completion?()
    }

    func invalidateAuthentication() {
        authenticationAllowed = false
        userAuthenticated = false
    }

    func allowAuthentication() {
        authenticationAllowed = true
    }

    override func isUserAuthenticated() -> Bool {
        return userAuthenticated
    }

    override func authenticateUser(password: String?, completion: ((Bool) -> Void)? = nil) {
        userAuthenticated = authenticationAllowed
        completion?(authenticationAllowed)
    }
}
