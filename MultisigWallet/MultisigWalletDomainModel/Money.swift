//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

/// Money Int type for representing money amount
public typealias MInt = BigInt

/// Money represents a specific amount in a currency denomination.
/// It is used both for fiat currencies and crypto-currencies.
public struct Money {

    public let amount: MInt
    public let currency: Currency

    public init(amount: MInt, currency: Currency) {
        self.amount = amount
        self.currency = currency
    }
}

public struct Currency {

    public let code: String
    /// Number of fractional digits for a currency.
    /// (10 ^ decimals) is the number of cents in one currency unit.
    public let decimals: Int

    public static let Ether = Currency(code: "ETH", decimals: 18)
    public static let Dollar = Currency(code: "USD", decimals: 2)

    public init(code: String, decimals: Int) {
        self.decimals = decimals
        self.code = code
    }

}

public extension Money {

    static func ether(_ amount: MInt) -> Money {
        return Money(amount: amount, currency: .Ether)
    }

}
