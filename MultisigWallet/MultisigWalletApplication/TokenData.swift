//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

public struct TokenData {

    public let name: String
    public let balance: BigInt?

    public init(name: String, balance: BigInt?) {
        self.name = name
        self.balance = balance
    }

}
