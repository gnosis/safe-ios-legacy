//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt
import MultisigWalletDomainModel

public struct TokenData: Equatable {

    public let address: String
    public let code: String
    public let name: String
    public let logoURL: URL?
    public let decimals: Int
    public let balance: BigInt?

    public init(address: String, code: String, name: String, logoURL: String, decimals: Int, balance: BigInt?) {
        self.address = address
        self.code = code
        self.name = name
        self.logoURL = URL(string: logoURL)
        self.decimals = decimals
        self.balance = balance
    }

    internal init(token: Token, balance: BigInt?) {
        self.init(
            address: token.address.value,
            code: token.code,
            name: token.name,
            logoURL: token.logoUrl,
            decimals: token.decimals,
            balance: balance)
    }

    func token() -> Token {
        return Token(
            code: code,
            name: name,
            decimals: decimals,
            address: Address(address),
            logoUrl: logoURL?.absoluteString ?? "")
    }

}
