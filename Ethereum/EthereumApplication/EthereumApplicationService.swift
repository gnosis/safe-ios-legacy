//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumDomainModel

public struct ExternallyOwnedAccountData: Equatable {

    public var address: String
    public var mnemonicWords: [String]

    public init(address: String, mnemonicWords: [String]) {
        self.address = address
        self.mnemonicWords = mnemonicWords
    }

}

open class EthereumApplicationService {

    public init() {}

    open func address(browserExtensionCode: String) -> String? {
        return DomainRegistry.encryptionService.address(browserExtensionCode: browserExtensionCode)
    }

    open func generateExternallyOwnedAccount() throws -> ExternallyOwnedAccountData {
        let account = try DomainRegistry.encryptionService.generateExternallyOwnedAccount()
        try DomainRegistry.externallyOwnedAccountRepository.save(account)
        return account.applicationServiceData
    }

    open func findExternallyOwnedAccount(by address: String) throws -> ExternallyOwnedAccountData? {
        guard let account = try DomainRegistry.externallyOwnedAccountRepository.find(by: Address(value: address)) else {
            return nil
        }
        return account.applicationServiceData
    }

}

fileprivate extension ExternallyOwnedAccount {

    var applicationServiceData: ExternallyOwnedAccountData {
        return ExternallyOwnedAccountData(address: address.value, mnemonicWords: mnemonic.words)
    }

}
