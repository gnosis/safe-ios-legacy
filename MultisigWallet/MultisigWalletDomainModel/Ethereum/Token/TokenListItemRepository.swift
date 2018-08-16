//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Represents collection of all token list items
public protocol TokenListItemRepository {

    /// Persists token list item
    ///
    /// - Parameter tokenListItem: item to save
    func save(_ tokenListItem: TokenListItem)

    /// Removes tokenListItem
    ///
    /// - Parameter tokenListItem: item to remove
    func remove(_ tokenListItem: TokenListItem)

    /// Searches for token list item by token id.
    ///
    /// - Parameters:
    ///   - id: token identifier
    /// - Returns: token list item if found, or nil otherwise.
    func find(id: TokenID) -> TokenListItem?

}
