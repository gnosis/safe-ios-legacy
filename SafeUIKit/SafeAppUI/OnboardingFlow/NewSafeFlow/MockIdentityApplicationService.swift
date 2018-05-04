//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import IdentityAccessApplication
import CommonTestSupport

class MockIdentityApplicationService: IdentityApplicationService {

    var shouldThrow = false
    var didCallConfirmPaperWallet = false
    var confirmedBrowserExtensionAddress = ""

    override func getOrCreateDraftSafe() throws -> DraftSafe {
        if shouldThrow { throw TestError.error }
        return try super.getOrCreateDraftSafe()
    }

    override func confirmPaperWallet(draftSafe: DraftSafe) {
        super.confirmPaperWallet(draftSafe: draftSafe)
        didCallConfirmPaperWallet = true
    }

    override func confirmBrowserExtension(draftSafe: DraftSafe, address: String) {
        super.confirmBrowserExtension(draftSafe: draftSafe, address: address)
        confirmedBrowserExtensionAddress = address
    }

}
