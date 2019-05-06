//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt
import Common

public class TokenID: BaseID {}

/// Represents a token.
public struct Token {

    /// Token id is the same as token Address in blockchain
    public var id: TokenID {
        return TokenID(address.value)
    }
    /// String code, like "ETH"
    public let code: String
    /// Token name like "Gnosis"
    public let name: String
    /// Number of fractional digits in one token.
    /// (10 ^ decimals) is the number of smallest token units in one token unit.
    public let decimals: Int
    /// Token contract address
    public let address: Address
    /// Token logo address
    public let logoUrl: String

    /// Ether token
    public static let Ether = Token(
        code: "ETH",
        name: "Ether",
        decimals: 18,
        address: Address("0x" + Data(repeating: 0, count: 20).toHexString()),
        logoUrl: "")

    /// Creates new Token with code, decimals and token contract address.
    ///
    /// - Parameters:
    ///   - code: token code
    ///   - name: token name
    ///   - decimals: number of decimal units in one token unit.
    ///   - address: token contract address
    ///   - logoUrl: token icon url address
    public init(code: String, name: String, decimals: Int, address: Address, logoUrl: String) {
        self.code = code
        self.name = name
        self.decimals = decimals
        self.address = address
        self.logoUrl = logoUrl
    }

}

extension Token: Equatable {}

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

extension TokenAmount: Equatable {}

public extension TokenAmount {

    /// Creates ether token with specified amount
    ///
    /// - Parameter amount: amount in Wei
    /// - Returns: token amount value object
    static func ether(_ amount: TokenInt) -> TokenAmount {
        return TokenAmount(amount: amount, token: .Ether)
    }

}
