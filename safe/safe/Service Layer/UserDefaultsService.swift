//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

protocol UserDefaultsServiceProtocol {
    func bool(for key: String) -> Bool?
    func setBool(_ value: Bool, for key: String)
    func deleteKey(_ key: String)
}

class InMemoryUserDefaults: UserDefaultsServiceProtocol {

    var dict = [String: Bool]()

    func bool(for key: String) -> Bool? {
        return dict[key]
    }

    func setBool(_ value: Bool, for key: String) {
        dict[key] = value
    }

    func deleteKey(_ key: String) {
        dict.removeValue(forKey: key)
    }

}

class UserDefaultsService: UserDefaultsServiceProtocol {

    func bool(for key: String) -> Bool? {
        if UserDefaults.standard.value(forKey: key) == nil {
            return nil
        }
        return UserDefaults.standard.bool(forKey: key)
    }

    func setBool(_ value: Bool, for key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    func deleteKey(_ key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }

}
