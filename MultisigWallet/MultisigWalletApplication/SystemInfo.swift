//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import CoreFoundation

class SystemInfo {

    class var buildNumber: Int? {
        guard let string = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String,
            let number = Int(string) else { return nil }
        return number
    }

    class var marketingVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

    class var bundleIdentifier: String? {
        return Bundle.main.bundleIdentifier
    }

}
