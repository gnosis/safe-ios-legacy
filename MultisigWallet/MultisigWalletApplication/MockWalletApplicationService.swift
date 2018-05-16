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
    private var _selectedWalletState: WalletState = .none {
        didSet {
            if oldValue != _selectedWalletState {
                notifySubscribers()
            }
        }
    }

    private var existingOwners: [OwnerType: String] = [:]
    private var accounts: [String: Int] = [:]
    private var minimumFunding: [String: Int] = [:]
    private var subscriptions: [String: () -> Void] = [:]

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
        _selectedWalletState = .deploymentStarted
    }

    public override func assignBlockchainAddress(_ address: String) {
        _selectedWalletState = .addressKnown
    }

    public override func update(account: String, newBalance: Int) {
        _selectedWalletState = .accountFunded
        if let minimum = minimumFunding[account], newBalance < minimum {
            _selectedWalletState = .notEnoughFunds
        }
    }

    public override func updateMinimumFunding(account: String, amount: Int) {
        minimumFunding[account] = amount
    }

    public override func markDeploymentAcceptedByBlockchain() {
        _selectedWalletState = .deploymentAcceptedByBlockchain
    }

    public override func markDeploymentFailed() {
        _selectedWalletState = .deploymentFailed
    }

    public override func markDeploymentSuccess() {
        _selectedWalletState = .deploymentSuccess
    }

    public override func abortDeployment() {
        _selectedWalletState = .newDraft
    }

    public override func addOwner(address: String, type: WalletApplicationService.OwnerType) {
        existingOwners[type] = address
    }

    public override func subscribe(_ update: @escaping () -> Void) -> String {
        let subscription = UUID().uuidString
        subscriptions[subscription] = update
        return subscription
    }

    public override func unsubscribe(subscription: String) {
        subscriptions.removeValue(forKey: subscription)
    }

    private func notifySubscribers() {
        subscriptions.values.forEach { $0() }
    }

    public override func ownerAddress(of type: WalletApplicationService.OwnerType) -> String? {
        return existingOwners[type]
    }
}
