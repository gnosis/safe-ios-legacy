//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public struct BroewserExtensionCode: Codable, Equatable {

    let expirationDate: Date
    let signature: Signature

    public init(expirationDate: Date, signature: Signature) {
        self.expirationDate = expirationDate
        self.signature = signature
    }

}
