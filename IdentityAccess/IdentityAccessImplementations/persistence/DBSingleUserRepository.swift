//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import IdentityAccessDomainModel

public class DBSingleUserRepository: SingleUserRepository {

    private let db: Database

    public init(db: Database) {
        self.db = db
    }

    public func nextId() -> UserID {
        return try! UserID()
    }

    public func save(_ user: User) throws {
        return try db.executeUpdate { conn in
            let stmt = try conn.prepare(statement: "INSERT OR REPLACE tbl_user VALUES (?, ?);")
            try stmt.set(user.id.id, at: 1)
            try stmt.set(user.password, at: 2)
            return stmt
        }
    }

    public func remove(_ user: User) throws {
        return try db.executeUpdate { conn in
            let stmt = try conn.prepare(statement: "DELETE FROM tbl_user WHERE user_id = ?;")
            try stmt.set(user.id.id, at: 1)
            return stmt
        }
    }

    public func primaryUser() -> User? {
        return db.executeQuery(mapUser) { conn in
            try conn.prepare(statement: "SELECT user_id, password FROM tbl_user LIMIT 1;")
        }
    }

    public func user(encryptedPassword: String) -> User? {
        return db.executeQuery(mapUser) { conn in
            let stmt = try conn.prepare(statement: "SELECT user_id, password FROM tbl_user WHERE password = ? LIMIT 1;")
            try stmt.set(encryptedPassword, at: 1)
            return stmt
        }
    }

    private func mapUser(_ rs: ResultSet) throws -> User? {
        guard try rs.advanceToNextRow(),
            let id = rs.string(at: 0),
            let password = rs.string(at: 1) else {
                return nil
        }
        return try User(id: try UserID(id), password: password)
    }

}
