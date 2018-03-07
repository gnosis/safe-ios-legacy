//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

protocol BiometricAuthenticationServiceProtocol {

    var isAvailable: Bool { get }

}

class FakeBiometricService: BiometricAuthenticationServiceProtocol {

    var isAvailable: Bool = false

}
