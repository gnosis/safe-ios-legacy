//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public struct BrowserExtensionCode: Codable, Equatable {

    let expirationDate: Date
    let signature: RSVSignature

    public private(set) var extensionAddress: String?

    enum Error: String, LocalizedError, Hashable {
        case invalidJsonFormat
    }

    enum CodingKeys: String, CodingKey {
        case expirationDate
        case signature
    }

    public init(expirationDate: Date, signature: RSVSignature, extensionAddress: String?) {
        self.expirationDate = expirationDate
        self.signature = signature
        self.extensionAddress = extensionAddress
    }

    public init(json: String) throws {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter.networkDateFormatter
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        guard let jsonData = json.data(using: .utf8) else {
            throw Error.invalidJsonFormat
        }
        do {
            self = try decoder.decode(BrowserExtensionCode.self, from: jsonData)
            extensionAddress = DomainRegistry.blockchainService.address(browserExtensionCode: json)
        } catch {
            throw Error.invalidJsonFormat
        }
    }

}
