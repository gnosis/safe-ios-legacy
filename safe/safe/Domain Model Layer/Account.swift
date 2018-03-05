//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

final class Account {

    private var password: String?
    private let userDefaultsService: UserDefaultsService

    init(userDefaultsService: UserDefaultsService) {
        self.userDefaultsService = userDefaultsService
    }

    var hasMasterPassword: Bool {
        return password != nil
    }

    func setMasterPassword(_ password: String) {
        self.password = password
    }

}
