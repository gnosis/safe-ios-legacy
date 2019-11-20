//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

struct SeedWord {
    var index: Int
    var value: String
    var style: SeedWordStyle

    var number: String {
        return String(index + 1)
    }
}

enum SeedWordStyle {
    case normal
    case focused
    case filled
    case empty
    case entered
    case error
}
