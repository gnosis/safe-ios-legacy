//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt
import CryptoSwift

/// Represents acceptable ranges for signature values
public struct ECDSASignatureBounds {

    // https://ethereum.github.io/yellowpaper/paper.pdf p.24 (280), (281), (282), (283)
    public static let secp256k1n =
        BigUInt("115792089237316195423570985008687907852837564279074904382605163141518161494337")
    public static let rRange = (BigUInt(0) ..< secp256k1n)
    public static let sRange = (BigUInt(0) ..< secp256k1n / 2 + 1)
    public static let vRange = (27...28)

    public static func isWithinBounds(r: String, s: String, v: Int) -> Bool {
        guard let r = BigUInt(r), let s = BigUInt(s) else { return false }
        return isWithinBounds(r: r, s: s, v: v)
    }

    public static func isWithinBounds(r: BigUInt, s: BigUInt, v: Int) -> Bool {
        return rRange.contains(r) && sRange.contains(s) && vRange.contains(v)
    }

}
