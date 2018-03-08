//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation
import LocalAuthentication

protocol BiometricAuthenticationServiceProtocol {

    func activate(completion: @escaping () -> Void)

}

class BiometricService: BiometricAuthenticationServiceProtocol {

    private let context: LAContext

    init(localAuthenticationContext: LAContext = LAContext()) {
        context = localAuthenticationContext
    }

    func activate(completion: @escaping () -> Void) {
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            // TODO: 07/03/2018 Localize
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Enable unlocking your master password with \(biometryType())", reply: { _, error in
                // TODO: 07/03/2018 Log Error
                if let error = error {
                    print("Error in evaluatePolicy: \(error)")
                }
                DispatchQueue.main.async {
                    completion()
                }
            })
        } else {
            completion()
        }
    }

    private func biometryType() -> String {
        // TODO: 07/03/2018 Localize
        if #available(iOS 11.0, *) {
            switch context.biometryType {
            case .touchID: return "Touch ID"
            case .faceID: return "Face ID"
            case .none:
                // TODO: 07/03/2018 Log. Should not happen
                return "None"
            }
        } else {
            return "Touch ID"
        }
    }

}
