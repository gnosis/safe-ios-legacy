//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

private final class BundleMarker {}

extension Bundle {

    static let safeUIKit = Bundle(for: BundleMarker.self)

}
