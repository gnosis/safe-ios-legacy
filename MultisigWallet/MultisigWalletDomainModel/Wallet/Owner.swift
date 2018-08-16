//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Represents wallet owner.
public struct Owner: Hashable, Codable {
    public internal(set) var address: Address
    public internal(set) var role: OwnerRole
}

public enum OwnerRole: String, Codable {
    case thisDevice
    case browserExtension
    case paperWallet

    static let all = [OwnerRole.thisDevice, .browserExtension, .paperWallet]
}
