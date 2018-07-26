//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

class TransactionConfirmedMessage: Message {

    public let hash: Data
    public let signature: EthSignature

    init?(userInfo: [AnyHashable: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: userInfo, options: []),
            let json = try? JSONDecoder().decode(JSON.self, from: data),
            json.type == "confirmTransaction" else { return nil }
        let hash = Data(ethHex: json.hash)
        guard !hash.isEmpty else { return nil }
        guard let v = Int(json.v) else { return nil }
        guard ECDSASignatureBounds.isWithinBounds(r: json.r, s: json.s, v: v) else { return nil }
        self.hash = hash
        self.signature = EthSignature(r: json.r, s: json.s, v: v)
        super.init(type: json.type)
    }

    private struct JSON: Decodable {
        var type: String
        var hash: String
        var r: String
        var s: String
        var v: String
    }

}
