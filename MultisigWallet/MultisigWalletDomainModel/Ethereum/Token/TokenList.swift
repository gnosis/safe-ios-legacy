//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public final class TokenListItem: IdentifiableEntity<TokenID> {

    public let token: Token
    public private(set) var status: TokenListItemStatus
    public private(set) var canPayTransactionFee: Bool
    public private(set) var sortingId: Int?
    public private(set) var updated: Date

    // NOTE: If you change enum values, then you'll need to run DB migration.
    // Adding new ones is OK as long as you don't change old values
    public enum TokenListItemStatus: String {
        case regular
        case whitelisted
        case blacklisted
    }

    public init(token: Token,
                status: TokenListItemStatus,
                canPayTransactionFee: Bool,
                sortingId: Int? = nil,
                updated: Date = Date()) {
        self.token = token
        self.status = status
        self.canPayTransactionFee = canPayTransactionFee
        self.sortingId = sortingId
        self.updated = updated
        super.init(id: token.id)
    }

    public func blacklist() {
        status = .blacklisted
    }

    public func whitelist() {
        status = .whitelisted
    }

    public func updateSortingId(with id: Int?) {
        sortingId = id
    }

}

extension TokenListItem: Decodable {

    enum CodingKeys: String, CodingKey {
        case `default`
        case code = "symbol"
        case name
        case decimals
        case address
        case logoUrl = "logoUri"
        case canPayTransactionFee = "gas"
    }

    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let code = try values.decode(String.self, forKey: .code)
        let name = try values.decode(String.self, forKey: .name)
        let decimals = try values.decode(Int.self, forKey: .decimals)
        let addressValue = try values.decode(String.self, forKey: .address)
        let address = Address(addressValue)
        let logoUrl = try values.decode(String.self, forKey: .logoUrl)
        let `default` = try values.decode(Bool.self, forKey: .default)
        let canPayTransactionFee = try values.decode(Bool.self, forKey: .canPayTransactionFee)

        let token = Token(code: code, name: name, decimals: decimals, address: address, logoUrl: logoUrl)
        let status: TokenListItemStatus = `default` ? .whitelisted : .regular
        self.init(token: token, status: status, canPayTransactionFee: canPayTransactionFee)
    }

}

public struct TokenList {

    public var results: [TokenListItem]

    public init(results: [TokenListItem]) {
        self.results = results
    }

}

extension TokenList: Decodable {}
