//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public struct WalletApplicationServiceConfiguration {

    public var transactionURLFormat: String
    public var chromeExtensionURL: URL
    public var privacyPolicyURL: URL
    public var termsOfUseURL: URL
    public var licensesURL: URL
    public var usesAPIv2: Bool

    public static let `default` = WalletApplicationServiceConfiguration(transactionURLFormat: "%@",
                                                                        chromeExtensionURL: .example,
                                                                        privacyPolicyURL: .example,
                                                                        termsOfUseURL: .example,
                                                                        licensesURL: .example,
                                                                        usesAPIv2: false)

    public init(transactionURLFormat: String,
                chromeExtensionURL: URL,
                privacyPolicyURL: URL,
                termsOfUseURL: URL,
                licensesURL: URL,
                usesAPIv2: Bool = false) {
        self.transactionURLFormat = transactionURLFormat
        self.chromeExtensionURL = chromeExtensionURL
        self.privacyPolicyURL = privacyPolicyURL
        self.termsOfUseURL = termsOfUseURL
        self.licensesURL = licensesURL
        self.usesAPIv2 = usesAPIv2
    }

    internal func transactionURL(`for` hash: String) -> URL {
         return URL(string: String(format: transactionURLFormat, hash))!
    }

}

fileprivate extension URL {
    static let example = URL(string: "https://example.org/")!
}
