//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

open class BaseInMemoryRepository<T: IdentifiableEntity<U>, U: Hashable> {

    private var items = Set<T>()

    public init() {}

    open func save(_ wallet: T) {
        items.insert(wallet)
    }

    open func remove(_ item: T) {
        if let foundItem = findByID(item.id) {
            items.remove(foundItem)
        }
    }

    open func findByID(_ itemID: U) -> T? {
        return items.first { $0.id == itemID }
    }

}
