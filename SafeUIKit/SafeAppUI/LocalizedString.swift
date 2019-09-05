//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

fileprivate class BundleMarker {}

func LocalizedString(_ key: String, comment: String) -> String {
    return NSLocalizedString(key, bundle: Bundle(for: BundleMarker.self), comment: comment)
}
