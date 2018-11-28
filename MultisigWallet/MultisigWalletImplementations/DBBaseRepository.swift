//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common
import Database

public protocol DBCodable {

    associatedtype ID: BaseID
    var id: ID { get }
    init(data: Data)
    func data() -> Data

}

struct DBBaseRepositorySQL {
    static let createTableFormat = """
CREATE TABLE IF NOT EXISTS %@ (
    id TEXT NOT NULL PRIMARY KEY,
    data BLOB NOT NULL
);
"""
    static let insertFormat = "INSERT OR REPLACE INTO %@ VALUES (?, ?);"
    static let deleteFormat = "DELETE FROM %@ WHERE id = ?;"
    static let findByID = "SELECT id, data FROM %@ WHERE id = ? LIMIT 1;"
    static let findFirst = "SELECT id, data FROM %@ LIMIT 1;"
    static let findAll = "SELECT id, data FROM %@;"

}

open class DBBaseRepository<T: DBCodable>: Assertable {

    enum Error: String, LocalizedError, Hashable {
        case invalidDataStoredInDatabase
    }

    public let db: Database

    public init(db: Database) {
        self.db = db
    }

    open var tableName: String {
        let typeName = String(reflecting: T.self).replacingOccurrences(of: ".", with: "_")
        return "tbl_\(typeName)"
    }

    open func setUp() {
        let sql = String(format: DBBaseRepositorySQL.createTableFormat, tableName)
        try! db.execute(sql: sql)
    }

    open func save(_ item: T) {
        let sql = String(format: DBBaseRepositorySQL.insertFormat, tableName)
        try! db.execute(sql: sql, bindings: [item.id.id, item.data()])
    }

    open func remove(_ item: T) {
        let sql = String(format: DBBaseRepositorySQL.deleteFormat, tableName)
        try! db.execute(sql: sql, bindings: [item.id.id])
    }

    open func findByID(_ itemID: T.ID) -> T? {
        let sql = String(format: DBBaseRepositorySQL.findByID, tableName)
        let results = try! db.execute(sql: sql, bindings: [itemID.id], resultMap: itemFromResultSet)
        guard let result = results.first as? T else { return nil }
        return result
    }

    open func findFirst() -> T? {
        let sql = String(format: DBBaseRepositorySQL.findFirst, tableName)
        let results = try! db.execute(sql: sql, resultMap: itemFromResultSet)
        guard let result = results.first as? T else { return nil }
        return result
    }

    private func itemFromResultSet(_ rs: ResultSet) -> T? {
        guard let id = rs.string(at: 0),
            let data = rs.data(at: 1) else {
            return nil
        }
        let item = T(data: data)
        try! assertEqual(item.id, T.ID(id), Error.invalidDataStoredInDatabase)
        return item
    }

    open func nextID() -> T.ID {
        return T.ID()
    }

    open func findAll() -> [T] {
        let sql = String(format: DBBaseRepositorySQL.findAll, tableName)
        return try! db.execute(sql: sql, resultMap: itemFromResultSet).compactMap { $0 }
    }

}
