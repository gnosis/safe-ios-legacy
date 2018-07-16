//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public class MockWalletApplicationService: WalletApplicationService {

    public enum Error: String, LocalizedError, Hashable {
        case error
    }

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

    private var walletAddress: String?

    public override var selectedWalletAddress: String? {
        return walletAddress
    }

    private var deploymentAmount: Int?

    public override var minimumDeploymentAmount: Int? {
        return deploymentAmount
    }

    public var didCreateNewDraft = false
    public var shouldThrow = false

    private var existingOwners: [OwnerType: String] = [:]
    private var accounts: [String: Int] = [:]
    private var minimumFunding: [String: Int] = [:]
    private var funds: [String: Int] = [:]
    private var subscriptions: [String: () -> Void] = [:]

    public func createReadyToUseWallet() {
        _hasReadyToUseWallet = true
        assignAddress("0x111ccccccccccccccccccccccccccccccccccccc")
        update(account: "ETH", newBalance: 100)
        _selectedWalletState = .readyToUse
    }

    public override func createNewDraftWallet() {
        _selectedWalletState = .newDraft
        didCreateNewDraft = true
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

    public func assignAddress(_ address: String) {
        walletAddress = address
        _selectedWalletState = .addressKnown
    }

    public override func update(account: String, newBalance: Int) {
        funds[account] = newBalance
        if let minimum = minimumFunding[account], newBalance >= minimum {
            _selectedWalletState = .accountFunded
        } else {
            _selectedWalletState = .notEnoughFunds
        }
    }

    public func updateMinimumFunding(account: String, amount: Int) {
        deploymentAmount = amount
        minimumFunding[account] = amount
    }

    public override func accountBalance(token: String) -> Int? {
        return funds[token]
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

    public override func addBrowserExtensionOwner(address: String, browserExtensionCode: String) throws {
        try throwIfNeeded()
        addOwner(address: address, type: .browserExtension)
    }

    public var authCalled = false
    public override func auth() throws {
        try throwIfNeeded()
        authCalled = true
    }

    private func throwIfNeeded() throws {
        if shouldThrow {
            throw Error.error
        }
    }

}
