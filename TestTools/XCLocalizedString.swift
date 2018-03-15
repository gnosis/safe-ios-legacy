//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

private final class BundleMarker {}

private let XCBundle = localizationBundle()

func XCLocalizedString(_ key: String) -> String {
    return NSLocalizedString(key, bundle: XCBundle, comment: "")
}

private func localizationBundle() -> Bundle {
    let testBundle = Bundle(for: BundleMarker.self)
    let localizedBundle: Bundle
    if let path = testBundle.path(forResource: "en", ofType: "lproj"), let bundle = Bundle(path: path) {
        localizedBundle = bundle
    } else {
        localizedBundle = testBundle
    }
    return localizedBundle
}
