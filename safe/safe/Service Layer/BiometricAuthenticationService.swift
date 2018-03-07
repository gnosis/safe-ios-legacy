//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

protocol BiometricAuthenticationServiceProtocol {

    func activate(completion: @escaping () -> Void)

}

class FakeBiometricService: BiometricAuthenticationServiceProtocol {

    func activate(completion: @escaping () -> Void) {
        completion()
    }

}
