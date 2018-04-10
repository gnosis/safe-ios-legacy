//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

public enum BiometryType {
    case none, touchID, faceID
}

public protocol BiometricAuthenticationService {

    var isAuthenticationAvailable: Bool { get }
    var biometryType: BiometryType { get }
    func activate(completion: @escaping () -> Void)
    func authenticate(completion: @escaping (Bool) -> Void)

}
