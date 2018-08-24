//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// In-memory implementation of token list items repository, used for testing purposes.
public class InMemoryTokenListItemRepository: TokenListItemRepository {

    private var items = [TokenID: TokenListItem]()

    public init() {}

    public func save(_ tokenListItem: TokenListItem) {
        if let existingItem = find(id: tokenListItem.id), existingItem.status == .whitelisted {
            if tokenListItem.status != .whitelisted {
                tokenListItem.updateSortingId(with: nil)
            }
        } else {
            if tokenListItem.status == .whitelisted {
                let lastWhitelistedId = whitelisted().last?.sortingId ?? -1
                tokenListItem.updateSortingId(with: lastWhitelistedId + 1)
            }
        }
        items[tokenListItem.id] = tokenListItem
    }

    public func remove(_ tokenListItem: TokenListItem) {
        items.removeValue(forKey: tokenListItem.id)
    }

    public func find(id: TokenID) -> TokenListItem? {
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
