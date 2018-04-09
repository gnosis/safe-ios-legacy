//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

protocol KeyValueStore {
    func bool(for key: String) -> Bool?
    func setBool(_ value: Bool, for key: String)
    func int(for key: String) -> Int?
    func setInt(_ value: Int, for key: String)
    func deleteKey(_ key: String)
}
