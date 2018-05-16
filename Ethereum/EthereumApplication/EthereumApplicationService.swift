//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public class EthereumApplicationService {

    public init() {}

    public func address(browserExtensionCode: String) -> String? {
        return nil
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
