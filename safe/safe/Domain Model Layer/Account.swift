//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

final class Account {

    private let userDefaultsService: UserDefaultsService

    init(userDefaultsService: UserDefaultsService) {
        self.userDefaultsService = userDefaultsService
    }

    var hasMasterPassword: Bool {
        return userDefaultsService.bool(for: UserDefaultsKey.masterPasswordWasSet.rawValue) ?? false
    }

    func setMasterPassword(_ password: String) {
        userDefaultsService.setBool(true, for: UserDefaultsKey.masterPasswordWasSet.rawValue)
    }

    func cleanupAllData() {
        userDefaultsService.deleteKey(UserDefaultsKey.masterPasswordWasSet.rawValue)
    }

    func checkMasterPassword(_ password: String) -> Bool {
        return false
    }

}
