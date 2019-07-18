//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Represents collection of all settings
public protocol AppSettingsRepository {

    /// Creates or replaces a setting
    ///
    /// - Parameters:
    ///   - setting: value to set
    ///   - key: setting key
    func set(setting: Any?, for key: String)

    /// Retrieves setting by key
    ///
    /// - Parameter key: setting key
    /// - Returns: value if it exists
    func setting(for key: String) -> Any?

    /// Deletes setting
    ///
    /// - Parameter key: setting's key
    func remove(for key: String)

}
