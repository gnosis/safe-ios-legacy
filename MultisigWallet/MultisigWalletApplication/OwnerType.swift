//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public enum OwnerType: String {
    case thisDevice
    case browserExtension
    case paperWallet
    case paperWalletDerived

    static let all: [OwnerType] = [.thisDevice, .browserExtension, .paperWallet, .paperWalletDerived]
}
