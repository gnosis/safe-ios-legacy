//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import CryptoSwift

public extension Data {

    init(ethHex: String) {
        var value = ethHex
        while value.hasPrefix("0x") { value = String(value.dropFirst(2)) }
        // padding needed because CryptoSwift's Data(hex:) pads from the end, not from the beginning of the data
        // which breaks integer conversions
        let paddingToByte = value.count % 2 == 1 ? "0" : ""
        value = paddingToByte + value
        self.init(hex: value)
    }

}
