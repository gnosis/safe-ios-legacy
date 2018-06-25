//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

/// Token Int type for representing tokens amount
public typealias TokenInt = BigInt

/// TokenAmount represents a specific amount in a token denomination.
public struct TokenAmount {

    public let amount: TokenInt
    public let token: Token

    public init(amount: TokenInt, token: Token) {
        self.amount = amount
        self.token = token
    }
}

public struct Token {

    public let code: String
    /// Number of fractional digits for a currency.
    /// (10 ^ decimals) is the number of cents in one currency unit.
    public let decimals: Int

    public static let Ether = Token(code: "ETH", decimals: 18)

    public init(code: String, decimals: Int) {
        self.decimals = decimals
        self.code = code
    }

}

public extension TokenAmount {

    static func ether(_ amount: TokenInt) -> TokenAmount {
        return TokenAmount(amount: amount, token: .Ether)
    }

}
