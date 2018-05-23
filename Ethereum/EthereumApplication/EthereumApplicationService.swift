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

    public struct ExternallyOwnedAccount: Equatable {

        public var address: String
        public var mnemonicWords: [String]

        public init(address: String, mnemonicWords: [String]) {
            self.address = address
            self.mnemonicWords = mnemonicWords
        }

    }

    open func generateExternallyOwnedAccount() -> ExternallyOwnedAccount {
        return ExternallyOwnedAccount(address: "0xa06a215ca4a54189e7f951c59f0431e33d0f38a0",
                                      mnemonicWords: [
                                        "alpha",
                                        "beta",
                                        "gamma",
                                        "delta",
                                        "epsilon",
                                        "zeta",
                                        "eta",
                                        "theta",
                                        "iota",
                                        "kappa",
                                        "lambda",
                                        "mu"])
    }

}
