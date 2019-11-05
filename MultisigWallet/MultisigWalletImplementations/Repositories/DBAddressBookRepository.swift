//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import CommonImplementations
import Database

public class DBAddressBookRepository: DBEntityRepository<AddressBookEntry, AddressBookEntryID>, AddressBookRepository {

    private let queue = DispatchQueue(label: "io.gnosis.safe.DBAddressBookRepository")

    public override var table: TableSchema {
        return .init("tbl_address_book",
                     "id TEXT NOT NULL PRIMARY KEY",
                     "name TEXT NOT NULL",
                     "address TEXT NOT NULL",
                     "type INTEGER NOT NULL")
    }

    public override func insertionBindings(_ object: AddressBookEntry) -> [SQLBindable?] {
        return bindable([object.id,
                         object.name,
                         object.address,
                         object.type.rawValue])
    }

    public override func objectFromResultSet(_ rs: ResultSet) throws -> AddressBookEntry? {
        guard let id: String = rs["id"],
            let name: String = rs["name"],
            let address: String = rs["address"],
            let type: Int = rs["type"],
            let entryType = AddressBookEntryType(rawValue: type) else { return nil }
        return AddressBookEntry(id: AddressBookEntryID(id), name: name, address: address, type: entryType)
    }

    public func find(address: String, types: [AddressBookEntryType]) -> [AddressBookEntry] {
        return find(key: "address", value: address, caseSensitive: false, orderBy: "name")
            .filter { types.contains($0.type) }
    }

    public override func all() -> [AddressBookEntry] {
        return super.all().sorted { $0.name < $1.name }
    }

    public override func save(_ item: AddressBookEntry) {
        queue.sync { [unowned self] in
            if item.type == .wallet {
                // we do not allow to create new wallet type entries with same address, but we allow to update them
                if let existing = self.find(address: item.address, types: [.wallet]).first, existing.id != item.id {
                    return
                }
            }
            // we can not use super.save with captured self here.
            self._save(item: item)
        }
    }

    private func _save(item: AddressBookEntry) {
        dispatchPrecondition(condition: .onQueue(queue))
        super.save(item)
    }

}
