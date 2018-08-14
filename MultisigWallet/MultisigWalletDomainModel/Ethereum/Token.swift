//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt
import Common

public class TokenID: BaseID {}

/// Represents a token.
public struct Token: Equatable {

    /// Token id is the same as token Address in blockchain
    public var id: TokenID {
        return TokenID(address.value)
    }
    /// String code, like "ETH"
    public let code: String
    /// Number of fractional digits in one token.
    /// (10 ^ decimals) is the number of smallest token units in one token unit.
    public let decimals: Int
    /// Token contract address
    public let address: Address

    /// Ether token
    public static let Ether = Token(code: "ETH", decimals: 18)

    /// Creates new Token with code and decimals numbers. Address is zero.
    ///
    /// - Parameters:
    ///   - code: token code
    ///   - decimals: token decimals number.
    public init(code: String, decimals: Int) {
        self.init(code: code,
                  decimals: decimals,
                  address: Address("0x" + Data(repeating: 0, count: 20).toHexString()))
    }

    /// Creates new Token with code, decimals and token contract address.
    ///
    /// - Parameters:
    ///   - code: token code
    ///   - decimals: number of decimal units in one token unit.
    ///   - address: token contract address
    public init(code: String, decimals: Int, address: Address) {
        self.decimals = decimals
        self.code = code
        self.address = address
    }

}

// MARK: - Token to/from String serialization
extension Token: CustomStringConvertible {

    public init?(_ value: String) {
        let components = value.components(separatedBy: "/")
        guard components.count == 3 else { return nil }
        guard let decimals = Int(components[1]) else { return nil }
        self.init(code: components[0], decimals: decimals, address: Address(components[2]))
    }

    public var description: String {
        return "\(code)/\(decimals)/\(address.value)"
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

    /// Creates ether token with specified amount
    ///
    /// - Parameter amount: amount in Wei
    /// - Returns: token amount value object
    static func ether(_ amount: TokenInt) -> TokenAmount {
        return TokenAmount(amount: amount, token: .Ether)
    }

}

// MARK: - TokenAmount to/from String conversion.
extension TokenAmount: CustomStringConvertible {

    public init?(_ value: String) {
        let components = value.components(separatedBy: " ")
        guard components.count == 2 else { return nil }
        guard let amount = TokenInt(components.first!), let token = Token(components.last!) else {
            return nil
        }
        self.init(amount: amount, token: token)
    }

    public var description: String {
        return "\(String(amount)) \(token)"
    }

}
