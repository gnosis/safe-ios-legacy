//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

private final class BundleMarker {}

extension Bundle {

    static let SafeUIKit = Bundle(for: BundleMarker.self)

}
