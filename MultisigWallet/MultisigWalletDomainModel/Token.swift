//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

public struct Token: Equatable {

    public let code: String
    /// Number of fractional digits in one token.
    /// (10 ^ decimals) is the number of smallest token units in one token unit.
    public let decimals: Int

    public static let Ether = Token(code: "ETH", decimals: 18)

    public init(code: String, decimals: Int) {
        self.decimals = decimals
        self.code = code
    }

}

/// Token Int type for representing tokens amount
public typealias TokenInt = BigInt

/// TokenAmount represents a specific amount in a token denomination.
public struct TokenAmount: Equatable {

    public let amount: TokenInt
    public let token: Token

    public init(amount: TokenInt, token: Token) {
        self.amount = amount
        self.token = token
    }
}

public extension TokenAmount {

    static func ether(_ amount: TokenInt) -> TokenAmount {
        return TokenAmount(amount: amount, token: .Ether)
    }

}
