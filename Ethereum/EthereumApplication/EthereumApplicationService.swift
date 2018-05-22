//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumDomainModel

public class EthereumApplicationService {

    public init() {}

    public func address(browserExtensionCode: String) -> String? {
        return DomainRegistry.encryptionService.address(browserExtensionCode: browserExtensionCode)
    }

    public struct ExternallyOwnedAccount: Equatable {

        public var address: String
        public var mnemonicWords: [String]

        public init(address: String, mnemonicWords: [String]) {
            self.address = address
            self.mnemonicWords = mnemonicWords
        }

    }

    public func generateExternallyOwnedAccount() -> ExternallyOwnedAccount {
        return ExternallyOwnedAccount(address: "address", mnemonicWords: [])
    }

}
