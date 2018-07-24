//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public struct SafeGasPriceResponse: Decodable {

    public let safeLow: String
    public let standard: String
    public let fast: String
    public let fastest: String
    public let lowest: String

    public init(safeLow: String,
                standard: String,
                fast: String,
                fastest: String,
                lowest: String) {
        self.safeLow = safeLow
        self.standard = standard
        self.fast = fast
        self.fastest = fastest
        self.lowest = lowest
    }

    enum CodingKeys: String, CodingKey {
        case safeLow = "safe_low"
        case lowest
        case fast
        case fastest
        case standard
    }

}
