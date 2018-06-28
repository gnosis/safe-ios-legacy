//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumDomainModel

public class MockEncryptionService: EncryptionDomainService {

    public var extensionAddress: String?

    public init() {}

    public func address(browserExtensionCode: String) -> String? {
        return extensionAddress
    }

    public func generateExternallyOwnedAccount() throws -> ExternallyOwnedAccount {
        return ExternallyOwnedAccount(address: Address(value: "address"),
                                      mnemonic: Mnemonic(words: ["one", "two", "three"]),
                                      privateKey: PrivateKey(data: Data()),
                                      publicKey: PublicKey(data: Data()))
    }

    public func randomUInt256() -> String {
        return "randomUInt256"
    }

    public func sign(message: String, privateKey: PrivateKey) throws -> RSVSignature {
        return (r: "", s: "", v: 27)
    }

}
