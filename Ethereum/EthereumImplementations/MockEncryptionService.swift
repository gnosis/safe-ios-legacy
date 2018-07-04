//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumDomainModel

public class MockEncryptionService: EncryptionDomainService {

    public func contractAddress(from: RSVSignature, for transaction: EthTransaction) throws -> String? {
        return "0x93a03e4223a1F281f07B442bfDcb34baF796772f"
    }

    public var extensionAddress: String?

    public var sign_output: RSVSignature = (r: "", s: "", v: 27)
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

    public func randomUInt256() -> String {
        return "51602277827206092161359189523869407094850301206236947198082645428468309668322"
    }

    public func sign(message: String, privateKey: PrivateKey) throws -> RSVSignature {
        sign_input = (message, privateKey)
        return sign_output
    }

}
