//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public class TokensDisplayListChanged: DomainEvent {}

/// Represents collection of all token list items.
public protocol TokenListItemRepository {

    /// Persists token list item and updated its sortingId.
    ///
    /// - Parameter tokenListItem: item to save.
    func save(_ tokenListItem: TokenListItem)

    /// Removes token list item.
    ///
    /// - Parameter tokenListItem: item to remove.
    func remove(_ tokenListItem: TokenListItem)

    /// Searches for token list item by token id.
    ///
    /// - Parameters:
    ///   - id: token identifier.
    /// - Returns: token list item if found, or nil otherwise.
    func find(id: TokenID) -> TokenListItem?

    /// Return all stored token list items.
    ///
    /// - Returns: token list items.
    func all() -> [TokenListItem]

    /// Return whitelisted token list items sorted by sortingId.
    ///
    /// - Returns: token list items.
    func whitelisted() -> [TokenListItem]

    /// Return payment tokens sorted by tokec code.
    ///
    /// - Returns: token list items.
    func paymentTokens() -> [TokenListItem]

}

public enum TokensListError: String, LocalizedError {
    case inconsistentData_notEqualToWhitelistedAmount
    case inconsistentData_notAmongWhitelistedToken
}


// MARK: - Domain Logic for TokenListItemRepository

public extension TokenListItemRepository {

    /// Domain logic regarding sorting Ids to be executed before saving in repo.
    ///
    /// - Parameter tokenListItem: token list item to save
    func prepareToSave(_ tokenListItem: TokenListItem) {
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
    }

    /// Whitelist a token.
    ///
    /// - Parameter token: necessary token.
    func whitelist(_ token: Token) {
        let existing = find(id: token.id)!
        let tokenListItem = TokenListItem(token: token,
                                          status: .whitelisted,
                                          canPayTransactionFee: existing.canPayTransactionFee)
        save(tokenListItem)
        DomainRegistry.eventPublisher.publish(TokensDisplayListChanged())
        DispatchQueue.global().async {
            try? DomainRegistry.accountUpdateService.updateAccountBalance(token: tokenListItem.token)
        }
    }

    /// Blacklist a token.
    ///
    /// - Parameter token: necessary token.
    func blacklist(_ token: Token) {
        let existing = find(id: token.id)!
        let tokenListItem = TokenListItem(token: token,
                                          status: .blacklisted,
                                          canPayTransactionFee: existing.canPayTransactionFee)
        save(tokenListItem)
        DomainRegistry.eventPublisher.publish(TokensDisplayListChanged())
    }

    /// Rearrange whitelisted tokens with new sorting ids.
    ///
    /// - Parameter tokens: new sorting order of tokens.
    func rearrange(tokens: [Token]) {
        let whitelisted = self.whitelisted()
        if tokens.count != whitelisted.count {
            DomainRegistry.errorStream.post(TokensListError.inconsistentData_notEqualToWhitelistedAmount)
        }
        for (index, token) in tokens.enumerated() {
            if let item = whitelisted.first(where: { $0.token.id == token.id }) {
                if item.sortingId == index { continue }
                item.updateSortingId(with: index)
                save(item)
            } else {
                DomainRegistry.errorStream.post(TokensListError.inconsistentData_notAmongWhitelistedToken)
            }
        }
        DomainRegistry.eventPublisher.publish(TokensDisplayListChanged())
    }

}
