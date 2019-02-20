//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Request to delete a device <-> other device pairing for the notification service.
public struct DeletePairRequest: Codable, Equatable {

    /// Address of the other device (browser extension, for example)
    public let device: String
    /// Signature of the code by the device owner
    public let signature: EthSignature

    public init(device: String, signature: EthSignature) {
        self.device = device
        self.signature = signature
    }

}
