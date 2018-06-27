//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public struct BrowserExtensionCode: Codable, Equatable {

    let expirationDate: Date
    let signature: RSVSignature

    enum Error: String, LocalizedError, Hashable {
        case invalidJsonFormat
    }

    public init(expirationDate: Date, signature: RSVSignature) {
        self.expirationDate = expirationDate
        self.signature = signature
    }

    public init(json: String) throws {
        let decoder = JSONDecoder()
        let dateFormatter = WalletDateFormatter()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        guard let jsonData = json.data(using: .utf8) else {
            throw Error.invalidJsonFormat
        }
        do {
            self = try decoder.decode(BrowserExtensionCode.self, from: jsonData)
        } catch {
            throw Error.invalidJsonFormat
        }
    }

}
