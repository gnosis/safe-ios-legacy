//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

open class MockEthereumApplicationService: EthereumApplicationService {

    enum Error: String, LocalizedError, Hashable {
        case error
    }

    open var resultAddressFromAnyBrowserExtensionCode: String?
    private var generatedAccount: ExternallyOwnedAccountData?
    public var shouldThrow = false

    open override func address(browserExtensionCode: String) -> String? {
        return resultAddressFromAnyBrowserExtensionCode
    }

    open func prepareToGenerateExternallyOwnedAccount(address: String, mnemonic: [String]) {
        generatedAccount = ExternallyOwnedAccountData(address: address, mnemonicWords: mnemonic)
    }

    open override func generateExternallyOwnedAccount() throws -> ExternallyOwnedAccountData {
        if shouldThrow {
            throw Error.error
        }
        return generatedAccount!
    }

}
