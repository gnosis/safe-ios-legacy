//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public struct PairingRequest: Codable, Equatable {

    public let temporaryAuthorization: BrowserExtensionCode
    public let signature: EthSignature
    public private(set) var deviceOwnerAddress: String?

    enum CodingKeys: String, CodingKey {
        case temporaryAuthorization
        case signature
    }

    public init(temporaryAuthorization: BrowserExtensionCode, signature: EthSignature, deviceOwnerAddress: String?) {
        self.temporaryAuthorization = temporaryAuthorization
        self.signature = signature
        self.deviceOwnerAddress = deviceOwnerAddress
    }

}
