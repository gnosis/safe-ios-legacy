//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumDomainModel

open class EthereumApplicationService {

    public init() {}

    open func address(browserExtensionCode: String) -> String? {
        return DomainRegistry.encryptionService.address(browserExtensionCode: browserExtensionCode)
    }

    public struct ExternallyOwnedAccountData: Equatable {

        public var address: String
        public var mnemonicWords: [String]

        public init(address: String, mnemonicWords: [String]) {
            self.address = address
            self.mnemonicWords = mnemonicWords
        }

    }

    open func generateExternallyOwnedAccount() throws -> ExternallyOwnedAccountData {
        let account = try DomainRegistry.encryptionService.generateExternallyOwnedAccount()
        return ExternallyOwnedAccountData(address: account.address.value, mnemonicWords: account.mnemonic.words)
    }

}
