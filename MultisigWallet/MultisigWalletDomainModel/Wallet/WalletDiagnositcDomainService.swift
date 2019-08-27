//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

open class WalletDiagnosticDomainService {

    public enum Error: String, Swift.Error {
        case deviceKeyNotFound
        case deviceKeyIsNotOwner
        case authenticatorIsNotOwner
        case paperWalletIsNotOwner
        case unexpectedSafeConfiguration
        case safeDoesNotExistInRelay
    }

    public init() {}

    /// Checks that the wallet is usable by the application.
    ///
    /// This call may take some time, as network requests are made. Run it on a background thread.
    ///
    /// The wallet has to be in .readyToUse state, otherwise the method will exit right away without error.
    ///
    /// - Parameter id: wallet ID
    /// - Throws: see `WalletDiagnosticDomainService.Error` for different errors.
    open func runDiagnostics(for id: WalletID) throws {
        guard let wallet = DomainRegistry.walletRepository.find(id: id), wallet.isReadyToUse else { return }

        guard let deviceOwner = wallet.owner(role: .thisDevice),
            DomainRegistry.externallyOwnedAccountRepository.find(by: deviceOwner.address) != nil else {
                throw Error.deviceKeyNotFound
        }

        let proxy = SafeOwnerManagerContractProxy(wallet.address)
        guard let remoteOwners = try? proxy.getOwners() else { return }

        // True only if owner exists for role but it is not in remote list.
        // Note that remote owners list has addresses lowercased.
        func remoteIsMissing(role: OwnerRole) -> Bool {
            guard let owner = wallet.owner(role: role) else { return false }
            return !remoteOwners.contains(Address(owner.address.value.lowercased()))
        }

        if remoteIsMissing(role: .thisDevice) {
            throw Error.deviceKeyIsNotOwner
        }

        if remoteIsMissing(role: .browserExtension) {
            throw Error.authenticatorIsNotOwner
        }

        if remoteIsMissing(role: .paperWallet) || remoteIsMissing(role: .paperWalletDerived) {
            throw Error.paperWalletIsNotOwner
        }

        guard let remoteConfirmationCount = try? proxy.getThreshold() else { return }
        guard wallet.confirmationCount == remoteConfirmationCount else {
            throw Error.unexpectedSafeConfiguration
        }

        guard (try? DomainRegistry.transactionRelayService.safeExists(at: wallet.address)) == true else {
            throw Error.safeDoesNotExistInRelay
        }
    }

}
