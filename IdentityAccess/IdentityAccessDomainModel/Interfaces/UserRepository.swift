//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol UserRepository {

    func save(_ user: User) throws
    func remove(_ user: User) throws
    func primaryUser() -> User?
    func nextId() -> UserID
    func user(encryptedPassword: String) -> User?

}
