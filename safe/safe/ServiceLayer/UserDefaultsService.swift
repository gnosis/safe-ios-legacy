//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

final class UserDefaultsService: KeyValueStore {

    func bool(for key: String) -> Bool? {
        if UserDefaults.standard.value(forKey: key) == nil {
            return nil
        }
        return UserDefaults.standard.bool(forKey: key)
    }

    func setBool(_ value: Bool, for key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    func int(for key: String) -> Int? {
        if UserDefaults.standard.value(forKey: key) == nil {
            return nil
        }
        return UserDefaults.standard.integer(forKey: key)
    }

    func setInt(_ value: Int, for key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    func deleteKey(_ key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }

}
