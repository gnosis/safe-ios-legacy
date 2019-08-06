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
    public var telegramURL: URL
    public var gitterURL: URL
    public var supportMail: String

    public static let `default` = WalletApplicationServiceConfiguration(transactionURLFormat: "%@",
                                                                        chromeExtensionURL: .example,
                                                                        privacyPolicyURL: .example,
                                                                        termsOfUseURL: .example,
                                                                        licensesURL: .example,
                                                                        telegramURL: .example,
                                                                        gitterURL: .example,
                                                                        supportMail: "")

    public init(transactionURLFormat: String,
                chromeExtensionURL: URL,
                privacyPolicyURL: URL,
                termsOfUseURL: URL,
                licensesURL: URL,
                telegramURL: URL,
                gitterURL: URL,
                supportMail: String) {
        self.transactionURLFormat = transactionURLFormat
        self.chromeExtensionURL = chromeExtensionURL
        self.privacyPolicyURL = privacyPolicyURL
        self.termsOfUseURL = termsOfUseURL
        self.licensesURL = licensesURL
        self.telegramURL = telegramURL
        self.gitterURL = gitterURL
        self.supportMail = supportMail
    }

    internal func transactionURL(`for` hash: String) -> URL {
         return URL(string: String(format: transactionURLFormat, hash))!
    }

}

fileprivate extension URL {
    static let example = URL(string: "https://example.org/")!
}
