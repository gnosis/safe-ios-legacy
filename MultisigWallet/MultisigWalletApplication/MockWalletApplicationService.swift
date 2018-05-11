//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public class MockWalletApplicationService: WalletApplicationService {

    public override var hasReadyToUseWallet: Bool {
        return _hasReadyToUseWallet
    }
    private var _hasReadyToUseWallet = false

    public func createReadyToUseWallet() {
        _hasReadyToUseWallet = true
    }

    public func createNewDraftWallet() {

    }

}
