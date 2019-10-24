//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import CommonImplementations
import Database

public class DBAddressBookRepository: DBEntityRepository<AddressBookEntry, AddressBookEntryID>, AddressBookRepository {

    public override var table: TableSchema {
        return .init("tbl_address_book",
                     "id TEXT NOT NULL PRIMARY KEY",
                     "name TEXT NOT NULL",
                     "address TEXT NOT NULL")
    }

    public override func insertionBindings(_ object: AddressBookEntry) -> [SQLBindable?] {
        return bindable([object.id,
                         object.name,
                         object.address])
    }

    public override func objectFromResultSet(_ rs: ResultSet) throws -> AddressBookEntry? {
        guard let id: String = rs["id"],
            let name: String = rs["name"],
            let address: String = rs["address"] else { return nil }
        return AddressBookEntry(id: AddressBookEntryID(id), name: name, address: address)
    }

    public func find(address: String) -> [AddressBookEntry] {
        return find(key: "address", value: address, orderBy: "name")
    }

    public override func all() -> [AddressBookEntry] {
        return super.all().sorted { $0.name < $1.name }
    }

}
