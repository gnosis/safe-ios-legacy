//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

struct AppConfig: Codable {

    var encryptionServiceChainId: Int
    var nodeServiceConfig: NodeServiceConfig
    var relayServiceURL: URL
    var notificationServiceURL: URL
    var tokenListServiceURL: URL
    var transactionWebURLFormat: String
    var chromeExtensionURL: String
    var termsOfUseURL: URL
    var privacyPolicyURL: URL

    enum CodingKeys: String, CodingKey {
        case encryptionServiceChainId = "encryption_service_chain_id"
        case nodeServiceConfig = "node_service"
        case relayServiceURL = "relay_service_url"
        case notificationServiceURL = "notification_service_url"
        case tokenListServiceURL = "token_list_service_url"
        case transactionWebURLFormat = "transaction_web_url_format"
        case chromeExtensionURL = "chrome_extension_url"
        case termsOfUseURL = "terms_of_use_url"
        case privacyPolicyURL = "privacy_policy_url"
    }

}

extension AppConfig {

    struct NodeServiceConfig: Codable {

        var url: URL
        var chainId: Int

        enum CodingKeys: String, CodingKey {
            case url
            case chainId = "chain_id"
        }

    }

}

extension AppConfig {

    init(contentsOfFile file: URL) throws {
        try self.init(data: Data(contentsOf: file))
    }

    init(data: Data) throws {
        self = try JSONDecoder().decode(AppConfig.self, from: data)
    }

    static func loadFromBundle() throws -> AppConfig? {
        guard let file = Bundle.main.url(forResource: "AppConfig", withExtension: "json") else {
            return nil
        }
        return try AppConfig(contentsOfFile: file)
    }

}
