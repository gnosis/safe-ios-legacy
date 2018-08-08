//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Indicates that safe was funded and safe creation transaction can be deployed.
public struct StartSafeCreationRequest: Encodable {

    public let safeAddress: String

    public init(safeAddress: String) {
        self.safeAddress = safeAddress
    }

}
