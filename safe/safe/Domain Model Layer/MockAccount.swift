//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation
@testable import safe

class MockAccount: AccountProtocol {

    var hasMasterPassword = false
    var didSavePassword = false
    var didCleanData = false

    func cleanupAllData() {
        didCleanData = true
    }

    func setMasterPassword(_ password: String) {
        didSavePassword = true
    }

}
