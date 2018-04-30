//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

private class BundleMarker {}

extension Bundle {
    static let identityAccessImplementations: Bundle? = {
        let thisBundle = Bundle(for: BundleMarker.self)
        guard let resourcesURL = thisBundle.url(forResource: "IdentityAccessImplementationsResources",
                                                withExtension: "bundle") else { return nil }
        return Bundle(path: resourcesURL.path)
    }()
}

func LocalizedString(_ key: String, comment: String) -> String {
    guard let bundle = Bundle.identityAccessImplementations else {
        return key
    }
    return NSLocalizedString(key, bundle: bundle, comment: comment)
}
