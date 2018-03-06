//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

protocol UserDefaultsService {
    func bool(for key: String) -> Bool?
    func setBool(_ value: Bool, for key: String)
    func deleteKey(_ key: String)
}

class InMemoryUserDefaults: UserDefaultsService {

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
