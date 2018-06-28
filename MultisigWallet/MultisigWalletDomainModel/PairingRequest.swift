//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public struct PairingRequest: Codable, Equatable {

    let temporaryAuthorization: BrowserExtensionCode
    let signature: RSVSignature

    public init(temporaryAuthorization: BrowserExtensionCode, signature: RSVSignature) {
        self.temporaryAuthorization = temporaryAuthorization
        self.signature = signature
    }

}
