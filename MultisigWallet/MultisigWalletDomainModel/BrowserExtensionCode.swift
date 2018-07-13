//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public struct BrowserExtensionCode: Codable, Equatable {

    public let expirationDate: Date
    public let signature: EthSignature
    public var extensionAddress: String?

    enum CodingKeys: String, CodingKey {
        case expirationDate
        case signature
    }

    public init(expirationDate: Date, signature: EthSignature, extensionAddress: String?) {
        self.expirationDate = expirationDate
        self.signature = signature
        self.extensionAddress = extensionAddress
    }

}
