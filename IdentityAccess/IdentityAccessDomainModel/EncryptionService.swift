//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Service to encrypt/hash password
public protocol EncryptionService {

    /// Encrypts plainText
    ///
    /// - Parameter plainText: to encrypt or hash
    /// - Returns: hashed/encrypted plainText
    func encrypted(_ plainText: String) -> String

}
