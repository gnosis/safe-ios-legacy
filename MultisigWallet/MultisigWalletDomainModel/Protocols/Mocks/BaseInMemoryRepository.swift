//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

open class BaseInMemoryRepository<T: IdentifiableEntity<U>, U: Hashable> {

    private var items = Set<T>()

    public init() {}

    open func save(_ wallet: T) throws {
        items.insert(wallet)
    }

    open func remove(_ item: T) throws {
        if let foundItem = try findByID(item.id) {
            items.remove(foundItem)
        }
    }

    open func findByID(_ itemID: U) throws -> T? {
        return items.first { $0.id == itemID }
    }

}
