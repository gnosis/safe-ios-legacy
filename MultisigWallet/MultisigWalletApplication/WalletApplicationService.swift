//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public class WalletApplicationService {

    public enum WalletState {
        case none
        case newDraft
    }

    public var selectedWalletState: WalletState {
        return .none
    }

    public var hasReadyToUseWallet: Bool {
        return false
    }

    public init() {}

}
