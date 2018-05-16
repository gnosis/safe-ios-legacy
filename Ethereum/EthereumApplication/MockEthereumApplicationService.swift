//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public class MockEthereumApplicationService: EthereumApplicationService {

    public var resultAddressFromAnyBrowserExtensionCode: String?
    private var generatedAccount: ExternallyOwnedAccount?

    public override func address(browserExtensionCode: String) -> String? {
        return resultAddressFromAnyBrowserExtensionCode
    }

    public func prepareToGenerateExternallyOwnedAccount(address: String, mnemonic: [String]) {
        generatedAccount = ExternallyOwnedAccount(address: address, mnemonicWords: mnemonic)
    }

    public override func generateExternallyOwnedAccount() -> ExternallyOwnedAccount {
        return generatedAccount!
    }

}
