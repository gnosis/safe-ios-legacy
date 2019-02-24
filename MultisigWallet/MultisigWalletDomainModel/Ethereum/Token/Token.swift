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

}

extension Token: Equatable {}

// MARK: - Token failable initializer from a String

public extension Token {

    init?(_ value: String) {
        let components = value.components(separatedBy: Token.separator)
        guard components.count == 5 else { return nil }
        guard let decimals = Int(components[2]) else { return nil }
        self.init(code: components[0],
                  name: components[1],
                  decimals: decimals,
                  address: Address(components[3]),
                  logoUrl: components[4])
    }

    fileprivate static let separator = "~~~"

}

// MARK: - Token conversion into a String

extension Token: CustomStringConvertible {

    public var description: String {
        return [code, name, String(decimals), address.value, logoUrl].joined(separator: Token.separator)
    }

}

/// Token Int type for representing tokens amount
public typealias TokenInt = BigInt

/// TokenAmount represents a specific amount in a token denomination.
public struct TokenAmount {

    public let amount: TokenInt
    public let token: Token

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

// MARK: - TokenAmount failable initializer from a String

extension TokenAmount {

    public init?(_ value: String) {
        let components = value.components(separatedBy: TokenAmount.separator)
        guard components.count == 2 else { return nil }
        guard let amount = TokenInt(components[0]), let token = Token(components[1]) else {
            return nil
        }
        self.init(amount: amount, token: token)
    }

    fileprivate static let separator = "==="

}

// MARK: - TokenAmount conversion into a String

extension TokenAmount: CustomStringConvertible {

    public var description: String {
        return [String(amount), token.description].joined(separator: TokenAmount.separator)
    }

}
