//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import CoreFoundation


public class SystemInfo {

    enum BundleIdentifier: String {
        case dev = "io.gnosis.safe.dev"
        case beta = "io.gnosis.safe.adhoc"
        case preProduction = "io.gnosis.safe.prerelease"
        case production = "io.gnosis.safe"
    }

    public class var buildNumber: Int? {
        guard let string = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String,
            let number = Int(string) else { return nil }
        return number
    }

    public class var marketingVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

    public class var bundleIdentifier: String? {
        return Bundle.main.bundleIdentifier
    }

    public class var bundleLabel: String? {
        guard let bundleIdentifier = bundleIdentifier,
            let identifier = BundleIdentifier(rawValue: bundleIdentifier) else { return nil }
        switch identifier {
        case .dev: return "Dev Rinkeby"
        case .beta: return "Beta Rinkeby"
        case .preProduction: return "Pre-Production Rinkeby"
        case .production: return "Production Mainnet"
        }
    }

}
