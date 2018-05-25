//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumKit
import IdentityAccessDomainModel

// TODO: rework without dependencies
public final class EthereumKitEncryptionService: EncryptionService {

    public init() {}

    public func encrypted(_ plainText: String) -> String {
        guard let data = plainText.data(using: .utf8) else { return plainText }
        return Crypto.hashSHA3_256(data).base64EncodedString()
    }

}
