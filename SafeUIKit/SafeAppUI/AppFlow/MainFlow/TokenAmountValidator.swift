//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

class TokenAmountValidator {

    enum ValidationError: Error {
        case empty
        case valueIsTooBig
        case valueIsTooSmall
        case valueIsNegative
        case notANumber
    }

    private let formatter: TokenNumberFormatter
    private let range: Range<BigInt>

    init(formatter: TokenNumberFormatter, range: Range<BigInt>) {
        self.formatter = formatter
        self.range = range
    }

    func validate(_ amount: String) -> ValidationError? {
        if amount.isEmpty { return .empty }
        guard let number = formatter.number(from: amount) else { return .notANumber }
        if number < 0 { return .valueIsNegative }
        if number < range.lowerBound { return .valueIsTooSmall }
        if number >= range.upperBound { return .valueIsTooBig }
        return nil
    }

}
