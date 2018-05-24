//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

open class MockEthereumApplicationService: EthereumApplicationService {

    open var resultAddressFromAnyBrowserExtensionCode: String?
    private var generatedAccount: ExternallyOwnedAccountData?

    open override func address(browserExtensionCode: String) -> String? {
        return resultAddressFromAnyBrowserExtensionCode
    }

    open func prepareToGenerateExternallyOwnedAccount(address: String, mnemonic: [String]) {
        generatedAccount = ExternallyOwnedAccountData(address: address, mnemonicWords: mnemonic)
    }

    open override func generateExternallyOwnedAccount() -> ExternallyOwnedAccountData {
        return generatedAccount!
    }

}
