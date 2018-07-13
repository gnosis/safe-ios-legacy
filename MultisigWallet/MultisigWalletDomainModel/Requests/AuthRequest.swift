//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public struct AuthRequest: Codable, Equatable {

    public let pushToken: String
    public let signature: EthSignature
    public private(set) var deviceOwnerAddress: String?

    enum CodingKeys: String, CodingKey {
        case pushToken
        case signature
    }

    public init(pushToken: String, signature: EthSignature, deviceOwnerAddress: String?) {
        self.pushToken = pushToken
        self.signature = signature
        self.deviceOwnerAddress = deviceOwnerAddress
    }

}
