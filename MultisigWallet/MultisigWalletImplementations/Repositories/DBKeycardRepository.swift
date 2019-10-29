//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import Database
import CommonImplementations

public class DBKeycardRepository: KeycardRepository {

    var pairingRepository: DBKeycardPairingRepository!
    var keyRepository: DBKeycardKeyRepository!

    public init(db: Database) {
        pairingRepository = DBKeycardPairingRepository(db: db)
        keyRepository = DBKeycardKeyRepository(db: db)
    }

    open func setUp() {
        pairingRepository.setUp()
        keyRepository.setUp()
    }

    // MARK: - Pairings

    open func save(_ pairing: KeycardPairing) {
        pairingRepository.save(pairing)
    }

    open func remove(_ pairing: KeycardPairing) {
        pairingRepository.remove(pairing)
    }

    open func findPairing(instanceUID: Data) -> KeycardPairing? {
        return pairingRepository.find(instanceUID: instanceUID)
    }

    // MARK: - Keys

    open func save(_ key: KeycardKey) {
        keyRepository.save(key)
    }

    open func remove(_ key: KeycardKey) {
        keyRepository.remove(key)
    }

    open func findKey(with address: Address) -> KeycardKey? {
        return keyRepository.find(address: address)
    }

}

class DBKeycardPairingRepository: DBAbstractRepository<KeycardPairing> {

    override var table: TableSchema {
        return TableSchema("tbl_keycard_pairings",
                           "instance_uid BLOB NOT NULL PRIMARY KEY",
                           "pairing_index INTEGER NOT NULL",
                           "pairing_key BLOB NOT NULL")
    }

    override func insertionBindings(_ object: KeycardPairing) -> [SQLBindable?] {
        return [object.instanceUID, object.index, object.key]
    }

    override func objectFromResultSet(_ rs: ResultSet) throws -> KeycardPairing? {
        guard let instanceUID: Data = rs["instance_uid"],
            let index: Int = rs["pairing_index"],
            let key: Data = rs["pairing_key"] else { return nil }
        return KeycardPairing(instanceUID: instanceUID, index: index, key: key)
    }

    override func primaryKeyBindings(_ item: KeycardPairing) -> [SQLBindable?] {
        return [item.instanceUID]
    }

    func find(instanceUID: Data) -> KeycardPairing? {
        return find(key: "instance_uid", value: instanceUID, orderBy: "rowid").first
    }

}

class DBKeycardKeyRepository: DBAbstractRepository<KeycardKey> {

    override var table: TableSchema {
        return TableSchema("tbl_keycard_keys",
                           "address TEXT NOT NULL PRIMARY KEY",
                           "instance_uid BLOB NOT NULL",
                           "master_key_uid BLOB NOT NULL",
                           "keypath TEXT NOT NULL",
                           "public_key BLOB NOT NULL")
    }

    override func insertionBindings(_ object: KeycardKey) -> [SQLBindable?] {
        return bindable([object.address,
                         object.instanceUID,
                         object.masterKeyUID,
                         object.keyPath,
                         object.publicKey])
    }

    override func objectFromResultSet(_ rs: ResultSet) throws -> KeycardKey? {
        guard let instanceUID: Data = rs["instance_uid"],
            let masterKeyUID: Data = rs["master_key_uid"],
            let keypath: String = rs["keypath"],
            let publicKey: Data = rs["public_key"],
            let addressString: String = rs["address"],
            let address = Address(serializedValue: addressString) else { return nil }
        return KeycardKey(address: address,
                          instanceUID: instanceUID,
                          masterKeyUID: masterKeyUID,
                          keyPath: keypath,
                          publicKey: publicKey)
    }

    override func primaryKeyBindings(_ item: KeycardKey) -> [SQLBindable?] {
        return bindable([item.address])
    }

    func find(address: Address) -> KeycardKey? {
        return find(key: "address", value: address.value, orderBy: "address").first
    }

}
