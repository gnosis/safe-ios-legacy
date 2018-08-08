//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Represents information required to pair browser extension app with multisig wallet.
public struct BrowserExtensionCode: Codable, Equatable {

    /// Code expiration date
    public let expirationDate: Date
    /// Signature of the browser extension
    public let signature: EthSignature
    /// Blockchain address of the browser extension
    public var extensionAddress: String?

    enum CodingKeys: String, CodingKey {
        case expirationDate
        case signature
    }

    /// Creates new code with specified parameters.
    ///
    /// - Parameters:
    ///   - expirationDate: code expiration date
    ///   - signature: browser extension's signature
    ///   - extensionAddress: browser extension's address
    public init(expirationDate: Date, signature: EthSignature, extensionAddress: String?) {
        self.expirationDate = expirationDate
        self.signature = signature
        self.extensionAddress = extensionAddress
    }

}
