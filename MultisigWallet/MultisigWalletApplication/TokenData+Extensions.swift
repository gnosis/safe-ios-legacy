//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common
import BigInt
import MultisigWalletDomainModel

extension TokenData {

    init(token: Token, balance: BigInt?) {
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

    static func empty() -> TokenData {
        return TokenData(address: "", code: "", name: "", logoURL: "", decimals: 18, balance: 0)
    }

}
