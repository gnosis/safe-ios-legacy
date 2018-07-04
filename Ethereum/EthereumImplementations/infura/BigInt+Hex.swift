//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt
import EthereumKit

public extension BigInt {

    /// Initialize with a hex value
    init?(hex string: String) {
        self.init(string.stripHexPrefix(), radix: 16)
    }

    /// Returns hex string representation with '0x' prefix.
    var hexString: String {
        return String(self, radix: 16).addHexPrefix()
    }

}
