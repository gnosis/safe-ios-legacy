//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public struct WalletApplicationServiceConfiguration {

    public var transactionURLFormat: String
    public var chromeExtensionURL: URL
    public var privacyPolicyURL: URL
    public var termsOfUseURL: URL

    public static let `default` = WalletApplicationServiceConfiguration(transactionURLFormat: "%@",
                                                                        chromeExtensionURL: .example,
                                                                        privacyPolicyURL: .example,
                                                                        termsOfUseURL: .example)

    public init(transactionURLFormat: String,
                chromeExtensionURL: URL,
                privacyPolicyURL: URL,
                termsOfUseURL: URL) {
        self.transactionURLFormat = transactionURLFormat
        self.chromeExtensionURL = chromeExtensionURL
        self.privacyPolicyURL = privacyPolicyURL
        self.termsOfUseURL = termsOfUseURL
    }

    internal func transactionURL(`for` hash: String) -> URL {
         return URL(string: String(format: transactionURLFormat, hash))!
    }

}

fileprivate extension URL {
    static let example = URL(string: "https://example.org/")!
}
