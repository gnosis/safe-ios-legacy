//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import DateTools

fileprivate extension Bundle {
    static let DateToolsBundle = Bundle(for: DateTools.Constants.self)
}

func DateToolsLocalized(_ key: String) -> String {
    return NSLocalizedString(key, tableName: "DateTools", bundle: Bundle.DateToolsBundle, value: "", comment: "")
}
