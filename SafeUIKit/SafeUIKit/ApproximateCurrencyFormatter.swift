//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

public class ApproximateCurrencyFormatter: NumberFormatter {

    private let maxIntegerPartLength = 11

    convenience init(locale: Locale) {
        self.init()
        self.locale = locale
        self.numberStyle = .currency
        self.minimumFractionDigits = 2
        self.maximumFractionDigits = 2
        self.minimumIntegerDigits = 1
        self.maximumIntegerDigits = maxIntegerPartLength
    }

    public func string(from number: BigInt, decimals: Int) -> String {
        guard let doubleValue = Double.value(from: number, decimals: decimals) else { return "" }
        return string(from: doubleValue)
    }

    public func string(from number: Double) -> String {
        guard number != 0 else { return "" }
        guard number / NSDecimalNumber(decimal: pow(10, maxIntegerPartLength)).doubleValue < 1 else { return "" }
        guard let stringValue = string(from: NSNumber(value: number)) else { return "" }
        return "≈ \(stringValue)"
    }

}
