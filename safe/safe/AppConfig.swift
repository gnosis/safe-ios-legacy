//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication
import SafeAppUI
import MultisigWalletDomainModel

struct AppConfig: Codable {

    var encryptionServiceChainId: Int
    var nodeServiceConfig: NodeServiceConfig
    var relayServiceURL: URL
    var notificationServiceURL: URL
    var transactionWebURLFormat: String
    var chromeExtensionURL: URL
    var appStoreReviewUrl: URL
    var termsOfUseURL: URL
    var privacyPolicyURL: URL
    var licensesURL: URL
    var telegramURL: URL
    var gitterURL: URL
    var supportMail: String
    var safeContractMetadata: SafeContractMetadata
    var featureFlags: [String: Bool]?
    var walletConnectChainId: Int

    enum CodingKeys: String, CodingKey {
        case encryptionServiceChainId = "encryption_service_chain_id"
        case nodeServiceConfig = "node_service"
        case relayServiceURL = "relay_service_url"
        case notificationServiceURL = "notification_service_url"
        case transactionWebURLFormat = "transaction_web_url_format"
        case chromeExtensionURL = "chrome_extension_url"
        case appStoreReviewUrl = "app_store_review_url"
        case termsOfUseURL = "terms_of_use_url"
        case privacyPolicyURL = "privacy_policy_url"
        case licensesURL = "licenses_url"
        case telegramURL = "telegram_url"
        case gitterURL = "gitter_url"
        case supportMail = "support_mail"
        case featureFlags = "feature_flags"
        case safeContractMetadata = "safe_contract_metadata"
        case walletConnectChainId = "wallet_connect_chain_id"
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

extension AppConfig {

    var walletApplicationServiceConfiguration: WalletApplicationServiceConfiguration {
        return WalletApplicationServiceConfiguration(transactionURLFormat: transactionWebURLFormat,
                                                     chromeExtensionURL: chromeExtensionURL,
                                                     appStoreReviewUrl: appStoreReviewUrl,
                                                     privacyPolicyURL: privacyPolicyURL,
                                                     termsOfUseURL: termsOfUseURL,
                                                     licensesURL: licensesURL,
                                                     telegramURL: telegramURL,
                                                     gitterURL: gitterURL,
                                                     supportMail: supportMail)
    }

}

extension SafeContractMetadata: Codable {

    enum CodingKeys: String, CodingKey {
        case multiSendContractAddress = "multi_send_contract_address"
        case proxyFactoryAddress = "proxy_factory_address"
        case safeFunderAddress = "safe_funder_address"
        case metadata = "contract_metadata"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(multiSendContractAddress: Address(values.decode(String.self, forKey: .multiSendContractAddress)),
                      proxyFactoryAddress: Address(values.decode(String.self, forKey: .proxyFactoryAddress)),
                      safeFunderAddress: Address(values.decode(String.self, forKey: .safeFunderAddress)),
                      metadata: values.decode([MasterCopyMetadata].self, forKey: .metadata))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(multiSendContractAddress.value, forKey: .multiSendContractAddress)
        try container.encode(proxyFactoryAddress.value, forKey: .proxyFactoryAddress)
        try container.encode(safeFunderAddress.value, forKey: .safeFunderAddress)
        try container.encode(metadata, forKey: .metadata)
    }

}

extension MasterCopyMetadata: Codable {

    enum CodingKeys: String, CodingKey {
        case address = "master_copy"
        case version = "version"
        case txTypeHash = "tx_type_hash"
        case domainSeparatorHash = "domain_separator_type_hash"
        case proxyCode = "proxy_code"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(address: Address(values.decode(String.self, forKey: .address)),
                      version: values.decode(String.self, forKey: .version),
                      txTypeHash: Data(ethHex: values.decode(String.self, forKey: .txTypeHash)),
                      domainSeparatorHash: Data(ethHex: values.decode(String.self, forKey: .domainSeparatorHash)),
                      proxyCode: Data(ethHex: values.decode(String.self, forKey: .proxyCode)))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(address.value, forKey: .address)
        try container.encode(version, forKey: .version)
        try container.encode(txTypeHash.toHexString().addHexPrefix(), forKey: .txTypeHash)
        try container.encode(domainSeparatorHash.toHexString().addHexPrefix(), forKey: .domainSeparatorHash)
        try container.encode(proxyCode.toHexString().addHexPrefix(), forKey: .proxyCode)
    }

}
