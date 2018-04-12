//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import IdentityAccessDomainModel

public class InMemoryKeyValueStore: KeyValueStore {

    private var store = [String: Any]()

    public init() {}

    public func bool(for key: String) -> Bool? {
        return get(key)
    }

    public func setBool(_ value: Bool, for key: String) {
        set(value, key)
    }

    public func int(for key: String) -> Int? {
        return get(key)
    }

    public func setInt(_ value: Int, for key: String) {
        set(value, key)
    }

    public func deleteKey(_ key: String) {
        store.removeValue(forKey: key)
    }

    private func get<T>(_ key: String) -> T? {
        return store[key] as? T
    }

    private func set<T>(_ value: T, _ key: String) {
        store[key] = value
    }

}
