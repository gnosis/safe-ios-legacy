//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public class WalletApplicationService {

    public enum WalletState {
        case none
        case newDraft
        case readyToDeploy
        case deploymentStarted
        case addressKnown
        case accountFunded
        case notEnoughFunds
        case deploymentAcceptedByBlockchain
        case deploymentSuccess
        case deploymentFailed
        case readyToUse
    }

    public enum OwnerType {
        case thisDevice
        case browserExtension
        case paperWallet

        static let all: [OwnerType] = [.thisDevice, .browserExtension, .paperWallet]
    }

    public var selectedWalletState: WalletState {
        return .none
    }

    public var hasReadyToUseWallet: Bool {
        return false
    }

    public init() {}

    public func createNewDraftWallet() {}

    public func startDeployment() {}

    public func updateMinimumFunding(account: String, amount: Int) {}

    public func update(account: String, newBalance: Int) {}

    public func assignBlockchainAddress(_ address: String) {}

    public func markDeploymentAcceptedByBlockchain() {}

    public func markDeploymentFailed() {}

    public func markDeploymentSuccess() {}

    public func abortDeployment() {}

    public func subscribe(_ update: @escaping () -> Void) -> String {
        return ""
    }

    public func unsubscribe(subscription: String) {}

    public func isOwnerExists(_ type: OwnerType) -> Bool {
        return false
    }

    public func addOwner(address: String, type: OwnerType) {}

    public func ownerAddress(of type: OwnerType) -> String? {
        return nil
    }

}
