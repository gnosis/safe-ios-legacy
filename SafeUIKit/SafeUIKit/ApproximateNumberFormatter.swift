//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

public class ApproximateNumberFormatter: NumberFormatter {

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
        let (integerPart, fractionalPart) = number.quotientAndRemainder(dividingBy: BigInt(10).power(decimals))

        let integerPartString = "\(integerPart)"
        guard integerPartString.count <= maxIntegerPartLength else { return "" }

        let fractionalPartInitialString = "\(fractionalPart)"
        let fractionalPartFinalString =
            String(repeating: "0", count: decimals - fractionalPartInitialString.count) + fractionalPartInitialString

        guard let doubleValue = Double("\(integerPartString).\(fractionalPartFinalString)"),
            let stringValue = string(from: NSNumber(value: doubleValue)) else { return "" }

        return "≈ \(stringValue)"
    }

}
