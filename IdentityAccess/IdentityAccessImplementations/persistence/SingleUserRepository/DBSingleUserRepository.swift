//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import IdentityAccessDomainModel
import Database

/// Database repository for storing user entity.
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
        static let findPrimaryUser = "SELECT user_id, password, session_id FROM tbl_user ORDER BY rowid LIMIT 1;"
        static let findUserByPassword =
            "SELECT user_id, password, session_id FROM tbl_user WHERE password = ? ORDER BY rowid LIMIT 1;"
    }

    private let db: Database

    public init(db: Database) {
        self.db = db
    }

    public func nextId() -> UserID {
        return UserID()
    }

    public func setUp() {
        try! db.execute(sql: SQL.createTable)
    }

    public func save(_ user: User) {
        try! db.execute(sql: SQL.insertUser, bindings: [user.id.id, user.password, user.sessionID?.id])
    }

    public func remove(_ user: User) {
        try! db.execute(sql: SQL.deleteUser, bindings: [user.id.id])
    }

    public func primaryUser() -> User? {
        guard let result = try? db.execute(sql: SQL.findPrimaryUser,
                                           resultMap: userFromResultSet).first as User?? else {
            return nil
        }
        return result
    }

    public func user(encryptedPassword: String) -> User? {
        guard let result = try? db.execute(sql: SQL.findUserByPassword,
                                           bindings: [encryptedPassword],
                                           resultMap: userFromResultSet).first as User?? else { return nil }
        return result
    }

    private func userFromResultSet(_ rs: ResultSet) throws -> User? {
        guard let id = rs.string(at: 0), let password = rs.string(at: 1) else {
            return nil
        }
        let user = User(id: UserID(id), password: password)
        if let sessionID = rs.string(at: 2) {
            user.attachSession(id: SessionID(sessionID))
        }
        return user
    }

}
