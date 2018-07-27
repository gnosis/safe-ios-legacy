//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public class SafeCreatedMessage: OutgoingMessage {

    public let safeAddress: Address

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
