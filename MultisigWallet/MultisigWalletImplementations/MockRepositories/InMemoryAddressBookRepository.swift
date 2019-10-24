//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

public class InMemoryAddressBookRepository: AddressBookRepository {

    private var entries = [AddressBookEntryID: AddressBookEntry]()

    public init() {}

    public func save(_ item: AddressBookEntry) {
        entries[item.id] = item
    }

    public func remove(_ item: AddressBookEntry) {
        entries.removeValue(forKey: item.id)
    }

    public func find(id: AddressBookEntryID) -> AddressBookEntry? {
        return entries[id]
    }

    public func find(address: String) -> [AddressBookEntry] {
        return entries.values
            .compactMap { $0.address.lowercased() == address.lowercased() ? $0 : nil }
            .sorted { $0.name < $1.name }
    }

    public func all() -> [AddressBookEntry] {
        return Array(entries.values).sorted { $0.name < $1.name }
    }

}
