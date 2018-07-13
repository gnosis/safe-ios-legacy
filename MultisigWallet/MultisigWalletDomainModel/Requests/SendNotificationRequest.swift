//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public struct SendNotificationRequest: Encodable {

    public var devices: [String]
    public var message: String
    public var signature: EthSignature

    public struct EmptyResponse: Decodable {}

    public init(message: String, to address: String, from signature: EthSignature) {
        self.message = message
        devices = [address]
        self.signature = signature
    }

}
