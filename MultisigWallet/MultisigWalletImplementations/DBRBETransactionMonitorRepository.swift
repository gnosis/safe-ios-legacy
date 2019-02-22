//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import Database
import CommonImplementations

public class DBRBETransactionMonitorRepository: RBETransactionMonitorRepository {

    var table: TableSchema = TableSchema("tbl_rbe_transaction_monitor_list",
                                         "transaction_id TEXT NOT NULL PRIMARY KEY",
                                         "created_date TEXT")

    private let db: Database

    public init(db: Database) {
        self.db = db
    }

    public func setUp() {
        try! db.execute(sql: table.createTableSQL)
    }

    public func save(_ entry: RBETransactionMonitorEntry) {
        try! db.execute(sql: table.insertSQL,
                        bindings: [entry.transactionID.id, String(entry.createdDate.timeIntervalSinceReferenceDate)])
    }

    public func remove(_ entry: RBETransactionMonitorEntry) {
        try! db.execute(sql: table.deleteSQL, bindings: [entry.transactionID.id])
    }

    public func find(id: TransactionID) -> RBETransactionMonitorEntry? {
        return try! db.execute(sql: table.findByPrimaryKeySQL, bindings: [id.id], resultMap: objectFromResultSet)
            .compactMap { $0 }.first
    }

    func objectFromResultSet(_ rs: ResultSet) -> RBETransactionMonitorEntry? {
        guard let id: String = rs["transaction_id"],
            let dateString: String = rs["created_date"],
            let dateTimeValue = TimeInterval(dateString) else { return nil }
        let date = Date(timeIntervalSinceReferenceDate: dateTimeValue)
        return RBETransactionMonitorEntry(transactionID: TransactionID(id), createdDate: date)
    }

    public func findAll() -> [RBETransactionMonitorEntry] {
        return try! db.execute(sql: table.findAllSQL, resultMap: objectFromResultSet).compactMap { $0 }
    }

}
