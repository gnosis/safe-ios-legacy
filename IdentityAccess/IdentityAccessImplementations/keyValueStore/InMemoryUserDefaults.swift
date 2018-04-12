//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import IdentityAccessDomainModel

class InMemoryUserDefaults: KeyValueStore {

    var dict = [String: Any]()

    func bool(for key: String) -> Bool? {
        return dict[key] as? Bool
    }

    func setBool(_ value: Bool, for key: String) {
        dict[key] = value
    }

    func int(for key: String) -> Int? {
        return dict[key] as? Int
    }

    func setInt(_ value: Int, for key: String) {
        dict[key] = value
    }

    func deleteKey(_ key: String) {
        dict.removeValue(forKey: key)
    }

}
