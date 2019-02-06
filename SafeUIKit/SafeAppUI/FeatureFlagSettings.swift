//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public class FeatureFlagSettings {

    public static var instance = FeatureFlagSettings(flags: [:])

    private var flags: [String: Bool] = [:]

    public init(flags: [String: Bool]) {
        self.flags = flags
    }

    public func turnOn(_ feature: String) {
        flags[feature] = true
    }

    public func turnOff(_ feature: String) {
        flags[feature] = false
    }

    public func isOn(_ feature: String) -> Bool {
        return flags[feature] == true
    }

    public func isOff(_ feature: String) -> Bool {
        return !isOn(feature)
    }

    public func turnOn<T>(_ feature: T) where T: RawRepresentable, T.RawValue == String {
        turnOn(feature.rawValue)
    }

    public func turnOff<T>(_ feature: T) where T: RawRepresentable, T.RawValue == String {
        turnOff(feature.rawValue)
    }

    public func isOn<T>(_ feature: T) -> Bool where T: RawRepresentable, T.RawValue == String {
        return isOn(feature.rawValue)
    }

    public func isOff<T>(_ feature: T) -> Bool where T: RawRepresentable, T.RawValue == String {
        return isOff(feature.rawValue)
    }

}
