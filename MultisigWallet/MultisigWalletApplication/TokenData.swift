//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

public struct TokenData {

    public let code: String
    public let name: String
    public let decimals: Int
    public let balance: BigInt?

    public init(code: String, name: String, decimals: Int, balance: BigInt?) {
        self.code = code
        self.name = name
        self.decimals = decimals
        self.balance = balance
    }

}
