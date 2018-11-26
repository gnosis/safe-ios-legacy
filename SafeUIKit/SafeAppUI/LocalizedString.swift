//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import DateTools

fileprivate class BundleMarker {}

fileprivate extension Bundle {
    static let SafeAppUI = Bundle(for: BundleMarker.self)
    static let DateToolsBundle = Bundle(for: DateTools.Constants.self)
}

func LocalizedString(_ key: String, comment: String) -> String {
    return NSLocalizedString(key, bundle: Bundle.SafeAppUI, comment: comment)
}

func DateToolsLocalized(_ key: String) -> String {
    return NSLocalizedString(key, tableName: "DateTools", bundle: Bundle.DateToolsBundle, value: "", comment: "")
}
