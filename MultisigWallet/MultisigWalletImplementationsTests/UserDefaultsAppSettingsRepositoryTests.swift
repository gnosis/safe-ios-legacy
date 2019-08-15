//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletImplementations
import MultisigWalletDomainModel

class UserDefaultsAppSettingsRepositoryTests: XCTestCase {

    func test_defaults() {
        let key = "io.gnosis.safe.MultisigWalletImplementations.UserDefaultsAppSettingsRepositoryTests"
        let value = "test"
        UserDefaults.standard.removeObject(forKey: key)
        XCTAssertNil(UserDefaults.standard.object(forKey: key))

        let repo = UserDefaultsAppSettingsRepository()

        XCTAssertNil(repo.setting(for: key))

        repo.set(setting: value, for: key)
        XCTAssertEqual(repo.setting(for: key) as! String, value)

        repo.remove(for: key)
        XCTAssertNil(repo.setting(for: key))

        UserDefaults.standard.removeObject(forKey: key)
    }

}
