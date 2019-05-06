//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Database
import MultisigWalletDomainModel
import CommonImplementations

extension Token: DBSerializable {

    static let separator = "~~~"

    public var serializedValue: SQLBindable {
        return serializedStringValue
    }

    var serializedStringValue: String {
        return [code, name, String(decimals), address.value, logoUrl].joined(separator: Token.separator)
    }

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

}

extension TokenAmount: DBSerializable {

    static let separator = "==="

    public var serializedValue: SQLBindable {
        return serializedStringValue
    }

    var serializedStringValue: String {
        return [String(amount), token.serializedStringValue].joined(separator: TokenAmount.separator)
    }

    init?(_ value: String) {
        let components = value.components(separatedBy: TokenAmount.separator)
        guard let amount = TokenInt(components[0]), let token = Token(components[1]), components.count == 2 else {
            return nil
        }
        self.init(amount: amount, token: token)
    }

}
