//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

public class MockEncryptionService: EncryptionDomainService {

    // NOTE: contractAddress and ecdsaRandomS are connected - you'll need to regenerate address
    // if you change random number
    public func contractAddress(from: EthSignature, for transaction: EthTransaction) throws -> String? {
        return "0x8c89eb758AF5Ee056Bc251328105F8893B057A05"
    }

    public var extensionAddress: String?

    public var sign_output = EthSignature(r: "", s: "", v: 27)
    public var sign_input: (message: String, privateKey: PrivateKey)?

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

    public func ecdsaRandomS() -> String {
        return "1809251394333065553493296640760748560207343510400633813116524750123642650623"
    }

    public func sign(message: String, privateKey: PrivateKey) throws -> EthSignature {
        sign_input = (message, privateKey)
        return sign_output
    }

}
