//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

// TODO: 06/03/18 add docs about protocol naming + rename existing
protocol AccountProtocol: class {

    var hasMasterPassword: Bool { get }
    func cleanupAllData()
    func setMasterPassword(_ password: String)

}

final class Account: AccountProtocol {

    static let shared = Account(userDefaultsService: InMemoryUserDefaults())
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
