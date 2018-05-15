//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public class MockWalletApplicationService: WalletApplicationService {

    public override var hasReadyToUseWallet: Bool {
        return _hasReadyToUseWallet
    }
    private var _hasReadyToUseWallet = false

    public override var selectedWalletState: WalletState {
        return _selectedWalletState
    }
    private var _selectedWalletState: WalletState = .none

    public var existingOwners: [OwnerType] = []

    public func createReadyToUseWallet() {
        _hasReadyToUseWallet = true
    }

    public override func createNewDraftWallet() {
        _selectedWalletState = .newDraft
    }

    public func removeSelectedWallet() {
        _selectedWalletState = .none
    }

    public override func isOwnerExists(_ type: OwnerType) -> Bool {
        return existingOwners.contains(type)
    }

    public func createReadyToDeployWallet() {
        _selectedWalletState = .readyToDeploy
    }

    public override func startDeployment() {
        _selectedWalletState = .pendingDeployment
    }

}
