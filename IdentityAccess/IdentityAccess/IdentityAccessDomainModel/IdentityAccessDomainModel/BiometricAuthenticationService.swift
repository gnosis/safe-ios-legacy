//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

enum BiometryType {
    case none, touchID, faceID
}

protocol BiometricAuthenticationService {

    var isAuthenticationAvailable: Bool { get }
    var biometryType: BiometryType { get }
    func activate(completion: @escaping () -> Void)
    func authenticate(completion: @escaping (Bool) -> Void)

}
