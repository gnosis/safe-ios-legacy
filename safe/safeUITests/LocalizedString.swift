//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import CommonTestSupport

func LocalizedString(_ key: String) -> String {
    let candidates = [
        XCLocalizedString(key),
        XCLocalizedString(key, table: "SafeUIKit"),
        XCLocalizedString(key, table: "SafeAppUI")
    ]
    return candidates.first { $0 != key } ?? candidates[0]
}
