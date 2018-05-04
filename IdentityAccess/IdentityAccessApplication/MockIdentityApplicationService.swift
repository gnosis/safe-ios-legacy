//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public class MockIdentityApplicationService: IdentityApplicationService {

    public var shouldThrow = false
    public var didCallConfirmPaperWallet = false
    public var confirmedBrowserExtensionAddress = ""

    public enum Error: String, LocalizedError, Hashable {
        case error
    }

    override public func getOrCreateDraftSafe() throws -> DraftSafe {
        if shouldThrow { throw Error.error }
        return try super.getOrCreateDraftSafe()
    }

    override public func confirmPaperWallet(draftSafe: DraftSafe) {
        super.confirmPaperWallet(draftSafe: draftSafe)
        didCallConfirmPaperWallet = true
    }

    override public func confirmBrowserExtension(draftSafe: DraftSafe, address: String) {
        super.confirmBrowserExtension(draftSafe: draftSafe, address: address)
        confirmedBrowserExtensionAddress = address
    }

}
