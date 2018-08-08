//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Notifies recipient that new wallet (safe) was created
public class SafeCreatedMessage: OutgoingMessage {

    /// Address of created wallet
    public let safeAddress: Address

    /// Creates new SafeCreatedMessage
    ///
    /// - Parameters:
    ///   - to: recipient's address
    ///   - from: sender's address
    ///   - safeAddress: created wallet address
    public required init(to: Address, from: Address, safeAddress: Address) {
        self.safeAddress = safeAddress
        super.init(type: "safeCreation", to: to, from: from)
    }

    private struct JSON: Encodable {
        var type: String
        var safe: String
    }

    public override var stringValue: String {
        return jsonString(from: JSON(type: type, safe: safeAddress.value))
    }

}
