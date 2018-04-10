//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation
import IdentityAccessDomainModel

public class MockEncryptionService: EncryptionServiceProtocol {

    public init() {}

    public func generateMnemonic() -> Mnemonic { return Mnemonic("test") }

    public func derivePrivateKey(from mnemonic: Mnemonic) -> PrivateKey { return PrivateKey(data: Data()) }

    public func derivePublicKey(from key: PrivateKey) -> PublicKey { return PublicKey(data: Data(), compressed: true) }

    public func deriveEthereumAddress(from key: PublicKey) -> EthereumAddress { return EthereumAddress(data: Data()) }

    public func sign(_ data: Data, _ key: PrivateKey) -> Signature { return Signature(data: Data()) }

    public func isValid(signature: Signature, for data: Data, with key: PublicKey) -> Bool { return true }

}
