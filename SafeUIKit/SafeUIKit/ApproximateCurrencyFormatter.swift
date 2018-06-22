//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

public class ApproximateCurrencyFormatter: NumberFormatter {

    convenience init(locale: Locale) {
        self.init()
        self.locale = locale
        self.numberStyle = .currency
        self.minimumFractionDigits = 2
        self.maximumFractionDigits = 2
        self.minimumIntegerDigits = 1
    }

    public func string(from number: BigInt, decimals: Int) -> String {
        guard let doubleValue = Double.value(from: number, decimals: decimals) else { return "" }
        return string(from: doubleValue)
    }

    public func string(from number: Double) -> String {
        guard number != 0 else { return "" }
        guard let stringValue = string(from: NSNumber(value: number)) else { return "" }
        return "≈ \(stringValue)"
    }

}
