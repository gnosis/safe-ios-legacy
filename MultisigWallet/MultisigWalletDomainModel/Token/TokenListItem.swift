//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class TokenListItem: IdentifiableEntity<TokenID> {

    public let token: Token
    public private(set) var sortingOrder: Int
    public private(set) var iconUrl: URL?
    public private(set) var status: TokenListItemStatus
    public private(set) var updated: Date

    public enum TokenListItemStatus: String {
        case regular
        case whitelisted
        case blacklisted
    }

    public init(token: Token, sortingOrder: Int, iconUrl: URL?, status: TokenListItemStatus) {
        self.token = token
        self.sortingOrder = sortingOrder
        self.iconUrl = iconUrl
        self.status = status
        self.updated = Date()
        super.init(id: token.id)
    }

}
