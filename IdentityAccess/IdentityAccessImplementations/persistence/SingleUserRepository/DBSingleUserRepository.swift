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
    password TEXT(100) NOT NULL,
    session_id TEXT
);
"""
        static let insertUser = "INSERT OR REPLACE INTO tbl_user VALUES (?, ?, ?);"
        static let deleteUser = "DELETE FROM tbl_user WHERE user_id = ?;"
        static let findPrimaryUser = "SELECT user_id, password, session_id FROM tbl_user LIMIT 1;"
        static let findUserByPassword = "SELECT user_id, password, session_id FROM tbl_user WHERE password = ? LIMIT 1;"
    }

    private let db: Database

    public init(db: Database) {
        self.db = db
    }

    public func nextId() -> UserID {
        return try! UserID()
    }

    public func setUp() throws {
        try db.executeUpdate(sql: SQL.createTable)
    }

    public func save(_ user: User) throws {
        return try db.executeUpdate { conn in
            let stmt = try conn.prepare(statement: SQL.insertUser)
            try stmt.set(user.id.id, at: 1)
            try stmt.set(user.password, at: 2)
            if let id = user.sessionID {
                try stmt.set(id.id, at: 3)
            } else {
                try stmt.setNil(at: 3)
            }
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
        return db.executeQuery(sql: SQL.findPrimaryUser, resultMap: userFromResultSet)
    }

    public func user(encryptedPassword: String) -> User? {
        return db.executeQuery(resultMap: userFromResultSet) { conn in
            let stmt = try conn.prepare(statement: SQL.findUserByPassword)
            try stmt.set(encryptedPassword, at: 1)
            return stmt
        }
    }

    private func userFromResultSet(_ rs: ResultSet) throws -> User? {
        guard try rs.advanceToNextRow(),
            let id = rs.string(at: 0),
            let password = rs.string(at: 1) else {
                return nil
        }
        let user = try User(id: try UserID(id), password: password)
        if let sessionID = rs.string(at: 2) {
            user.attachSession(id: try SessionID(sessionID))
        }
        return user
    }

}
