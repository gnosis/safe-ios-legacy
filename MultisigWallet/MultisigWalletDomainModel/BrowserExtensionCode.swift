//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public struct BrowserExtensionCode: Codable, Equatable {

    let expirationDate: Date
    let signature: RSVSignature

    public init(expirationDate: Date, signature: RSVSignature) {
        self.expirationDate = expirationDate
        self.signature = signature
    }

}
