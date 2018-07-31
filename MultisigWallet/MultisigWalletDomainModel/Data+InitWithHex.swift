//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import CryptoSwift

public extension Data {

    init(ethHex: String) {
        var value = ethHex
        while value.hasPrefix("0x") || value.hasPrefix("0X") { value = String(value.dropFirst(2)) }
        // if ethHex is not full byte, Data(hex:) adds nibble at the end, but we need it in the beginning
        let paddingToByte = value.count % 2 == 1 ? "0" : ""
        value = paddingToByte + value
        self.init(hex: value)
    }

}
