//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Keycard

protocol KeycardFacade: class {

    func selectApplet() throws -> ApplicationInfo

    func activate(pin: String, puk: String, password: String) throws

    var pairing: Pairing? { get }
    func setPairing(key: Data, index: Int)
    func resetPairing()
    func pair(password: String) throws

    func openSecureChannel() throws

    func authenticate(pin: String) throws

    func generateMasterKey() throws -> Data
    func exportPublicKey(path: String, makeCurrent: Bool) throws -> Data

}

extension KeycardCommandSet: KeycardFacade {

    func selectApplet() throws -> ApplicationInfo {
        try ApplicationInfo(select().checkOK().data)
    }

    func activate(pin: String, puk: String, password: String) throws {
        try initialize(pin: pin, puk: puk, pairingPassword: password).checkOK()
    }

    func setPairing(key: Data, index: Int) {
        pairing = Pairing(pairingKey: Array(key), pairingIndex: UInt8(index))
    }

    func resetPairing() {
        pairing = nil
    }

    func openSecureChannel() throws {
        try autoOpenSecureChannel()
    }

    func pair(password: String) throws {
        try autoPair(password: password)
    }

    func authenticate(pin: String) throws {
        try verifyPIN(pin: pin).checkAuthOK()
    }

    func generateMasterKey() throws -> Data {
        try Data(generateKey().checkOK().data)
    }

    func exportPublicKey(path: String, makeCurrent: Bool) throws -> Data {
        let tlv = try exportKey(path: path, makeCurrent: makeCurrent, publicOnly: true).checkOK().data
        let keypair = try BIP32KeyPair(fromTLV: tlv)
        return Data(keypair.publicKey)
    }

}
