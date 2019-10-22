//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

private class BundleMarker {}

func LocalizedString(_ key: String, comment: String) -> String {
    return NSLocalizedString(key, bundle: Bundle(for: BundleMarker.self), comment: comment)
}
