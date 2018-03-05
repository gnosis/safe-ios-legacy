//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

protocol UserDefaultsService {
    func bool(for key: String) -> Bool?
    func setBool(_ value: Bool, for key: String)
    func deleteKey(_ key: String)
}
