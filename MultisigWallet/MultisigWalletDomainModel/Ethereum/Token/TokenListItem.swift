//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public final class TokenListItem: IdentifiableEntity<TokenID>, Decodable {

    public let token: Token
    public private(set) var status: TokenListItemStatus
    public private(set) var sortingId: Int?
    public private(set) var updated: Date

    public enum TokenListItemStatus: String {
        case regular
        case whitelisted
        case blacklisted
    }

    enum CodingKeys: String, CodingKey {
        case token
        case `default`
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        token = try values.decode(Token.self, forKey: .token)
        let defaut = try values.decode(Bool.self, forKey: .default)
        status = defaut ? .whitelisted : .regular
        updated = Date()
        super.init(id: token.id)
    }

    public init(token: Token, status: TokenListItemStatus, sortingId: Int? = nil) {
        self.token = token
        self.status = status
        self.sortingId = sortingId
        self.updated = Date()
        super.init(id: token.id)
    }

}
