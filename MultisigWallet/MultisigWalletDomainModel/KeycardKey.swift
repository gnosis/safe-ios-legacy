//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public struct KeycardKey: Equatable {

    public var address: Address
    public var instanceUID: Data
    public var masterKeyUID: Data
    public var keyPath: String
    public var publicKey: Data

    public init(address: Address,
                instanceUID: Data,
                masterKeyUID: Data,
                keyPath: String,
                publicKey: Data) {
        self.address = address
        self.instanceUID = instanceUID
        self.masterKeyUID = masterKeyUID
        self.keyPath = keyPath
        self.publicKey = publicKey
    }
}
