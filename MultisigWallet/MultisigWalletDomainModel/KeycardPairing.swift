//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public struct KeycardPairing: Equatable {

    public var instanceUID: Data
    public var index: Int
    public var key: Data

    public init(instanceUID: Data, index: Int, key: Data) {
        self.instanceUID = instanceUID
        self.index = index
        self.key = key
    }

}
