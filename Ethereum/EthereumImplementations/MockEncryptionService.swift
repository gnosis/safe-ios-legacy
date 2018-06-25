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

    public func randomData(byteCount: Int) throws -> Data {
        return Data(repeating: 1, count: byteCount)
    }

    public func sign(message: String, privateKey: PrivateKey) throws -> Data {
        // swiftlint:disable:next line_length
        return "0x0ec487cc67649c87f6ef059d21079c6e3023cd6b31b1e9b6ac82d1bff53f67e63a811b3e70f52459897b0bc03e5cdb3d482c982b2d4a4f68f17fd35c973473521c".data(using: .utf8)!
    }

}
