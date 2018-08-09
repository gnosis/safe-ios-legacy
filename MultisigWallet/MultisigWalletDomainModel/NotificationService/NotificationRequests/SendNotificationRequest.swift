//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Request to deliver notification to other paired devices
public struct SendNotificationRequest: Encodable {

    /// List of devices to send notification to
    public var devices: [String]
    /// String message to send to recipients
    public var message: String
    /// Sender's signature of the message
    public var signature: EthSignature

    public struct EmptyResponse: Decodable {}

    /// Creates new request
    ///
    /// - Parameters:
    ///   - message: message to send
    ///   - address: recipient address
    ///   - signature: sender's signature of the message
    public init(message: String, to address: String, from signature: EthSignature) {
        self.message = message
        devices = [address]
        self.signature = signature
    }

}
