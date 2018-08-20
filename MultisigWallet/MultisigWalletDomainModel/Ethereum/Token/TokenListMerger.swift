//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public class TokenListMergedEvent: DomainEvent {}

public final class TokenListMerger {

    private var repository: TokenListItemRepository { return DomainRegistry.tokenListItemRepository }

    public init() {}

    /// Merge stored token items with latest info from the service.
    ///
    /// - Parameter tokenList: array of latest token list items.
    public func mergeStoredTokenItems(with tokenList: [TokenListItem]) {
        deleteStoredTokenItemsThatAreNotInList(tokenList)
        let remainingTokenList = updateWhitelistedAndBlacklistedTokenItems(with: tokenList)
        createOrUpdateTokenItems(with: remainingTokenList)
        DomainRegistry.eventPublisher.publish(TokenListMergedEvent())
    }

    /// Delete all saved token list items that are not in latest list and are not whitelisted.
    ///
    /// - Parameter tokenList: array of latest token list items
    private func deleteStoredTokenItemsThatAreNotInList(_ tokenList: [TokenListItem]) {
        let newTokenListSet = Set(tokenList)
        let storedNotWhitelistedTokenListSet = Set(repository.all().filter { $0.status != .whitelisted })
        let toDeleteSet = storedNotWhitelistedTokenListSet.subtracting(newTokenListSet)
        toDeleteSet.forEach { repository.remove($0) }
    }

    /// Updates whitelisted and blacklisted token items and remove them from incoming tokenList.
    /// Whitelisted and blacklisted token items should keep its status and local sorting number.
    ///
    /// - Parameter tokenList: array of latest token list items.
    /// - Returns: array of remaining token list items.
    private func updateWhitelistedAndBlacklistedTokenItems(with tokenList: [TokenListItem]) -> [TokenListItem] {
        let whitelistedAndBlacklistedTokenItems = repository.all().filter {
            $0.status == .whitelisted || $0.status == .blacklisted
        }
        var remainingTokenItems = [TokenListItem]()
        tokenList.forEach { latestItem in
            if let itemToUpdate = whitelistedAndBlacklistedTokenItems.first(where: { item in
                item.token.id == latestItem.token.id }) {
                updateTokenItemWithTokenInfoOnly(itemToUpdate, with: latestItem)
            } else {
                remainingTokenItems.append(latestItem)
            }
        }
        return remainingTokenItems
    }

    /// Updates token item. Updated token item should keep its status and sorting number.
    ///
    /// - Parameters:
    ///   - tokenItem: token list item to update.
    ///   - item: token list item with latest info.
    private func updateTokenItemWithTokenInfoOnly(_ item: TokenListItem, with latestItem: TokenListItem) {
        let updatedItem = TokenListItem(token: latestItem.token, status: item.status, sortingId: item.sortingId)
        repository.save(updatedItem)
    }

    /// Create or update stored token list items from the list.
    ///
    /// - Parameter tokenList: array of latest token list items.
    private func createOrUpdateTokenItems(with tokenList: [TokenListItem]) {
        tokenList.forEach { repository.save($0) }
    }

}
