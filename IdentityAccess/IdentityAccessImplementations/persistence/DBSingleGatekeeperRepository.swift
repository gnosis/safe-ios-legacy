//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import IdentityAccessDomainModel
import Common

public class DBSingleGatekeeperRepository: SingleGatekeeperRepository, Assertable {

    struct SQL {
        static let createTable = """
CREATE TABLE IF NOT EXISTS tbl_gatekeeper (
    gatekeeper_id TEXT NOT NULL PRIMARY KEY,
    data BLOB NOT NULL
);
"""
        static let insertGatekeeper = "INSERT OR REPLACE INTO tbl_gatekeeper VALUES (?, ?);"
        static let deleteGatekeeper = "DELETE FROM tbl_gatekeeper WHERE gatekeeper_id = ?;"
        static let findGatekeeper = "SELECT gatekeeper_id, data FROM tbl_gatekeeper LIMIT 1;"
    }

    public enum Error: Swift.Error, Hashable {
        case invalidGatekeeperIdStoredWithData
    }

    private let db: Database

    public init(db: Database) {
        self.db = db
    }

    public func setUp() throws {
        try db.executeUpdate(sql: SQL.createTable)
    }

    public func save(_ gatekeeper: Gatekeeper) throws {
        try db.executeUpdate { conn in
            let stmt = try conn.prepare(statement: SQL.insertGatekeeper)
            try stmt.set(gatekeeper.id.id, at: 1)
            try stmt.set(try gatekeeper.data(), at: 2)
            return stmt
        }
    }

    public func remove(_ gatekeeper: Gatekeeper) throws {
        try db.executeUpdate { conn in
            let stmt = try conn.prepare(statement: SQL.deleteGatekeeper)
            try stmt.set(gatekeeper.id.id, at: 1)
            return stmt
        }
    }

    public func gatekeeper() -> Gatekeeper? {
        return db.executeQuery(sql: SQL.findGatekeeper) { [unowned self] rs in
            guard try rs.advanceToNextRow(),
                let id = rs.string(at: 0),
                let data = rs.data(at: 1) else {
                    return nil
            }
            let gatekeeper = try Gatekeeper(data: data)
            try self.assertEqual(gatekeeper.id, try GatekeeperID(id), Error.invalidGatekeeperIdStoredWithData)
            return gatekeeper
        }
    }

    public func nextId() -> GatekeeperID {
        return try! GatekeeperID()
    }

}
