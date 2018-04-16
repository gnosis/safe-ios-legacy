//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public enum BiometryType {
    case none, touchID, faceID
}

public protocol BiometricAuthenticationService {

    var isAuthenticationAvailable: Bool { get }
    var biometryType: BiometryType { get }
    @available(*, deprecated, message: "Use activate() method")
    func activate(completion: @escaping () -> Void)
    func activate() throws
    @available(*, deprecated, message: "Use authenticate() method")
    func authenticate(completion: @escaping (Bool) -> Void)
    func authenticate() -> Bool
}
