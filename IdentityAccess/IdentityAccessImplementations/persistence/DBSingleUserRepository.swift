//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import IdentityAccessDomainModel

public class DBSingleUserRepository: SingleUserRepository {

    struct SQL {
        static let createTable = """
CREATE TABLE IF NOT EXISTS tbl_user (
    user_id TEXT NOT NULL PRIMARY KEY,
    password TEXT(100) NOT NULL
);
"""
        static let insertUser = "INSERT OR REPLACE tbl_user VALUES (?, ?);"
        static let deleteUser = "DELETE FROM tbl_user WHERE user_id = ?;"
        static let findPrimaryUser = "SELECT user_id, password FROM tbl_user LIMIT 1;"
        static let findUserByPassword = "SELECT user_id, password FROM tbl_user WHERE password = ? LIMIT 1;"
    }

    private let db: Database

    public init(db: Database) {
        self.db = db
    }

    public func nextId() -> UserID {
        return try! UserID()
    }

    public func setUp() throws {
        try db.executeUpdate(SQL.createTable)
    }

    public func save(_ user: User) throws {
        return try db.executeUpdate { conn in
            let stmt = try conn.prepare(statement: SQL.insertUser)
            try stmt.set(user.id.id, at: 1)
            try stmt.set(user.password, at: 2)
            return stmt
        }
    }

    public func remove(_ user: User) throws {
        return try db.executeUpdate { conn in
            let stmt = try conn.prepare(statement: SQL.deleteUser)
            try stmt.set(user.id.id, at: 1)
            return stmt
        }
    }

    public func primaryUser() -> User? {
        return db.executeQuery(mapUser, SQL.findPrimaryUser)
    }

    public func user(encryptedPassword: String) -> User? {
        return db.executeQuery(mapUser) { conn in
            let stmt = try conn.prepare(statement: SQL.findUserByPassword)
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
