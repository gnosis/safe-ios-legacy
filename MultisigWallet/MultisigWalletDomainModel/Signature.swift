//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public struct RSVSignature: Codable, Equatable {

    let r: String
    let s: String
    let v: Int

    public init(r: String, s: String, v: Int) {
        self.r = r
        self.s = s
        self.v = v
    }

}
