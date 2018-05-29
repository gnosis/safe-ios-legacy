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

public struct SafeCreationTransactionData: Equatable {

    public var safe: String
    public var payment: Int

    public init(safe: String, payment: Int) {
        self.safe = safe
        self.payment = payment
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

    open func createSafeCreationTransaction(owners: [String], confirmationCount: Int) throws
        -> SafeCreationTransactionData {
        return SafeCreationTransactionData(safe: "", payment: 0)
    }

}

fileprivate extension ExternallyOwnedAccount {

    var applicationServiceData: ExternallyOwnedAccountData {
        return ExternallyOwnedAccountData(address: address.value, mnemonicWords: mnemonic.words)
    }

}
