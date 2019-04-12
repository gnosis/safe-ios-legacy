//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Represents JSON Auth request to register for receiving notifications
public struct AuthRequest: Codable, Equatable {

    /// Push notification token
    public let pushToken: String
    /// Signature to authorize receiving of notifications
    public let signature: EthSignature
    /// Address of the signer (mobile device wallet owner address).
    public private(set) var deviceOwnerAddress: String?

    enum CodingKeys: String, CodingKey {
        case pushToken
        case signature
    }

    /// Creates new request
    ///
    /// - Parameters:
    ///   - pushToken: push notification token
    ///   - signature: Sender signature
    ///   - deviceOwnerAddress: Address of the signer
    public init(pushToken: String, signature: EthSignature, deviceOwnerAddress: String?) {
        self.pushToken = pushToken
        self.signature = signature
        self.deviceOwnerAddress = deviceOwnerAddress
    }

}

/// Represents JSON Auth request to register for receiving notifications
public struct AuthRequestV2: Codable, Equatable {

    /// Push notification token
    public let pushToken: String
    /// Signature to authorize receiving of notifications
    public let signature: EthSignature
    /// Integer build number of the app
    public let buildNumber: Int
    /// User-facing version string
    public let versionName: String
    /// Platform of the app (ios)
    public let client: String
    /// Bundle identifier of the app
    public let bundle: String

    /// Address of the signer (mobile device wallet owner address).
    public private(set) var deviceOwnerAddress: String?

    enum CodingKeys: String, CodingKey {
        case pushToken
        case signature
        case buildNumber
        case versionName
        case client
        case bundle
    }

    /// Creates new request
    ///
    /// - Parameters:
    ///   - pushToken: push notification token
    ///   - signature: Sender signature
    ///   - deviceOwnerAddress: Address of the signer
    public init(pushToken: String,
                signature: EthSignature,
                buildNumber: Int,
                versionName: String,
                client: String,
                bundle: String,
                deviceOwnerAddress: String?) {
        self.pushToken = pushToken
        self.signature = signature
        self.buildNumber = buildNumber
        self.versionName = versionName
        self.client = client
        self.bundle = bundle
        self.deviceOwnerAddress = deviceOwnerAddress
    }

}
