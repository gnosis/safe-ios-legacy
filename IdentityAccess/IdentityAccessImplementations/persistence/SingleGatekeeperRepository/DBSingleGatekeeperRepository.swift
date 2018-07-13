//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import IdentityAccessDomainModel
import Common
import Database

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
        try db.execute(sql: SQL.createTable)
    }

    public func save(_ gatekeeper: Gatekeeper) throws {
        try db.execute(sql: SQL.insertGatekeeper, bindings: [gatekeeper.id.id, try gatekeeper.data()])
    }

    public func remove(_ gatekeeper: Gatekeeper) throws {
        try db.execute(sql: SQL.deleteGatekeeper, bindings: [gatekeeper.id.id])
    }

    public func gatekeeper() -> Gatekeeper? {
        guard let result = try? db.execute(sql: SQL.findGatekeeper,
                                           resultMap: gatekeeperFromResultSet).first as? Gatekeeper else { return nil }
        return result
    }

    private func gatekeeperFromResultSet(_ rs: ResultSet) throws -> Gatekeeper? {
        guard let id = rs.string(at: 0), let data = rs.data(at: 1) else {
                return nil
        }
        let gatekeeper = try Gatekeeper(data: data)
        try self.assertEqual(gatekeeper.id, GatekeeperID(id), Error.invalidGatekeeperIdStoredWithData)
        return gatekeeper
    }

    public func nextId() -> GatekeeperID {
        return GatekeeperID()
    }

}
