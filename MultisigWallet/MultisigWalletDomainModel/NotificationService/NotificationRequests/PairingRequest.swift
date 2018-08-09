//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Request to pair device owner with browser extension owner. Encapsulates browser extension code received
/// from browser extension pairing process.
public struct PairingRequest: Codable, Equatable {

    /// Code used to pair with browser extension
    public let temporaryAuthorization: BrowserExtensionCode
    /// Signature of the code by device owner
    public let signature: EthSignature
    /// Address of signer
    public private(set) var deviceOwnerAddress: String?

    enum CodingKeys: String, CodingKey {
        case temporaryAuthorization
        case signature
    }

    /// Creates new request.
    ///
    /// - Parameters:
    ///   - temporaryAuthorization: browser extension's authorization code
    ///   - signature: Signature of the device owner
    ///   - deviceOwnerAddress: Address of the signer
    public init(temporaryAuthorization: BrowserExtensionCode, signature: EthSignature, deviceOwnerAddress: String?) {
        self.temporaryAuthorization = temporaryAuthorization
        self.signature = signature
        self.deviceOwnerAddress = deviceOwnerAddress
    }

}
