//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public struct Signature: Codable, Equatable {

    let v: Int
    let r: String
    let s: String

    public init(v: Int, r: String, s: String) {
        self.v = v
        self.r = r
        self.s = s
    }

}
