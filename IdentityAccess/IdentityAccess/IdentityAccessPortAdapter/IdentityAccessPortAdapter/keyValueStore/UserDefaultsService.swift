//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation
import IdentityAccessDomainModel

public final class UserDefaultsService: KeyValueStore {

    public init() {}

    public func bool(for key: String) -> Bool? {
        if UserDefaults.standard.value(forKey: key) == nil {
            return nil
        }
        return UserDefaults.standard.bool(forKey: key)
    }

    public func setBool(_ value: Bool, for key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    public func int(for key: String) -> Int? {
        if UserDefaults.standard.value(forKey: key) == nil {
            return nil
        }
        return UserDefaults.standard.integer(forKey: key)
    }

    public func setInt(_ value: Int, for key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    public func deleteKey(_ key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }

}
