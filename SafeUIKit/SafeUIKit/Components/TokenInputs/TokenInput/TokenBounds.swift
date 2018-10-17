//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

struct TokenBounds {

    static let maxTokenValue = BigInt(2).power(256) - 1
    static let minTokenValue = BigInt(0)

    static let maxDigitsCount = String(maxTokenValue).count
    static let minDigitsCount = 0

    static func isWithinBounds(value: BigInt) -> Bool {
        return value >= TokenBounds.minTokenValue && value <= TokenBounds.maxTokenValue
    }

    static func hasCorrectDigitCount(_ value: Int) -> Bool {
        return value >= TokenBounds.minDigitsCount && value <= TokenBounds.maxDigitsCount
    }

}
