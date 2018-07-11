//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public struct AuthRequest: Codable, Equatable {

    public let pushToken: String
    public let signature: EthSignature

    public init(pushToken: String, signature: EthSignature) {
        self.pushToken = pushToken
        self.signature = signature
    }

}
