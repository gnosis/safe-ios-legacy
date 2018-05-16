//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public class WalletApplicationService {

    public enum WalletState {
        case none
        case newDraft
        case readyToDeploy
        case pendingDeployment
    }

    public var selectedWalletState: WalletState {
        return .none
    }

    public var hasReadyToUseWallet: Bool {
        return false
    }

    public init() {}

    public func createNewDraftWallet() {

    }

    public enum OwnerType {
        case thisDevice
        case browserExtension
        case paperWallet

        static let all: [OwnerType] = [.thisDevice, .browserExtension, .paperWallet]
    }

    public func isOwnerExists(_ type: OwnerType) -> Bool {
        return false
    }

    public func addOwner(address: String, type: OwnerType) {
    }

    public func ownerAddress(of type: OwnerType) -> String? {
        return nil
    }

    public func startDeployment() {
    }

}
