//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

public typealias KeyPathComponent = UInt32

public protocol KeycardDomainService {

    var isAvailable: Bool { get }

    func pair(password: String, pin: String, keyPathComponent: KeyPathComponent) throws -> Address
    func generateCredentials() -> (pin: String, puk: String, pairingPassword: String)
    func initialize(pin: String, puk: String, pairingPassword: String, keyPathComponent: KeyPathComponent) throws -> Address
    func forgetKey(for address: Address)
    func sign(hash: Data, by address: Address, pin: String) throws -> Data
    func unblock(puk: String, pin: String, address: Address) throws
}
