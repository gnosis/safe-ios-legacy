//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public struct StartSafeCreationRequest: Encodable {

    public let safeAddress: String

    public init(safeAddress: String) {
        self.safeAddress = safeAddress
    }

}
