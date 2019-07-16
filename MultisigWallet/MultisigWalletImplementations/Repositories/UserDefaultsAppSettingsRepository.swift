//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

public class UserDefaultsAppSettingsRepository: AppSettingsRepository {

    private var defaults: UserDefaults { return .standard }

    public init() {}

    public func set(setting: Any?, for key: String) {
        defaults.set(setting, forKey: key)
    }

    public func setting(for key: String) -> Any? {
        return defaults.value(forKey: key)
    }

    public func remove(for key: String) {
        defaults.removeObject(forKey: key)
    }

}
