//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

/// In-memory implementation of token list items repository, used for testing purposes.
public class InMemoryTokenListItemRepository: TokenListItemRepository {

    private var items = [TokenID: TokenListItem]()

    public init() {}

    public func save(_ tokenListItem: TokenListItem) {
        prepareToSave(tokenListItem)
        items[tokenListItem.id] = tokenListItem
    }

    public func remove(_ tokenListItem: TokenListItem) {
        items.removeValue(forKey: tokenListItem.id)
    }

    public func find(id: TokenID) -> TokenListItem? {
        if id == Token.Ether.id { return TokenListItem(token: .Ether, status: .whitelisted) }
        return items[id]
    }

    public func all() -> [TokenListItem] {
        return Array(items.values).sorted { $0.token.code < $1.token.code }
    }

    public func whitelisted() -> [TokenListItem] {
        return Array(items.values).filter { $0.status == .whitelisted }.sorted {
            let a = $0.sortingId
            let b = $1.sortingId
            if a != nil && b != nil {
                return a! < b!
            } else {
                return a != nil && b == nil
            }
        }
    }

}
