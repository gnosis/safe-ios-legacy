//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Represents JSON Auth request to register for receiving notifications
public struct AuthRequest: Codable, Equatable {

    /// Push notification token
    public let pushToken: String
    /// Signatures of this request by authorizing addresses (to support multiple wallets with different owners
    /// existing in the same app with same push token).
    public let signatures: [EthSignature]
    /// Integer build number of the app
    public let buildNumber: Int
    /// User-facing version string
    public let versionName: String
    /// Platform of the app (ios)
    public let client: String
    /// Bundle identifier of the app
    public let bundle: String

    /// Addresses of the signers (mobile device wallet owner address).
    public private(set) var deviceOwnerAddresses: [String] = []

    enum CodingKeys: String, CodingKey {
        case pushToken
        case signatures
        case buildNumber
        case versionName
        case client
        case bundle
    }

    /// Create new request
    ///
    /// - Parameters:
    ///   - pushToken: FCM push token
    ///   - signatures: signatures of the owners that authorize this push token
    ///   - buildNumber: app build number
    ///   - versionName: app version number
    ///   - client: the platform name
    ///   - bundle: app identifier
    ///   - deviceOwnerAddress: the address that signs the request
    public init(pushToken: String,
                signatures: [EthSignature],
                buildNumber: Int,
                versionName: String,
                client: String,
                bundle: String,
                deviceOwnerAddresses: [String]) {
        self.pushToken = pushToken
        self.signatures = signatures
        self.buildNumber = buildNumber
        self.versionName = versionName
        self.client = client
        self.bundle = bundle
        self.deviceOwnerAddresses = deviceOwnerAddresses
        assert(signatures.count == deviceOwnerAddresses.count)
    }

}
