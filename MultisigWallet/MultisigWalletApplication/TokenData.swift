//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

public struct TokenData {

    public let code: String
    public let name: String
    public let logoURL: URL?
    public let decimals: Int
    public let balance: BigInt?

    public init(code: String, name: String, logoURL: String, decimals: Int, balance: BigInt?) {
        self.code = code
        self.name = name
        self.logoURL = URL(string: logoURL)
        self.decimals = decimals
        self.balance = balance
    }

}
