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

    private var existingOwners: [OwnerType: String] = [:]

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
        return existingOwners[type] != nil
    }

    public func createReadyToDeployWallet() {
        _selectedWalletState = .readyToDeploy
        existingOwners = [
            .thisDevice: "thisDeviceAddress",
            .browserExtension: "browserExtensionAddress",
            .paperWallet: "paperWalletAddress"
        ]
    }

    public override func startDeployment() {
        _selectedWalletState = .pendingDeployment
    }

    public override func addOwner(address: String, type: WalletApplicationService.OwnerType) {
        existingOwners[type] = address
    }

    public override func ownerAddress(of type: WalletApplicationService.OwnerType) -> String? {
        return existingOwners[type]
    }
}
