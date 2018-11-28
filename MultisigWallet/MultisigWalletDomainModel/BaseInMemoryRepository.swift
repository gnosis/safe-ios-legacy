//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

/// Base implementation of in-memory repository holding identifiable entity identified by Hashable ID.
open class BaseInMemoryRepository<T: IdentifiableEntity<U>, U: Hashable> {

    /// items in the repository
    internal var items = Set<T>()

    /// Creates new repository
    public init() {}

    /// Saves entity in the repository
    ///
    /// - Parameter item: entity to save
    open func save(_ item: T) {
        items.insert(item)
    }

    /// Removes entity from the repository, if finds it by identifier
    ///
    /// - Parameter item: entity to remove
    open func remove(_ item: T) {
        if let foundItem = findByID(item.id) {
            items.remove(foundItem)
        }
    }

    /// Searches for entity by its identifier
    ///
    /// - Parameter itemID: entity identifier
    /// - Returns: entity if found, nil otherwise.
    open func findByID(_ itemID: U) -> T? {
        return items.first { $0.id == itemID }
    }

    open func findAll() -> [T] {
        return Array(items)
    }

}
