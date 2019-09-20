//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import UIKit
import Common

open class WalletDiagnosticDomainService: WalletDiagnosticService {

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
        guard isFileAccessPossible() else { return }
        guard let wallet = DomainRegistry.walletRepository.find(id: id), wallet.isReadyToUse else { return }

        guard let deviceOwner = wallet.owner(role: .thisDevice),
            DomainRegistry.externallyOwnedAccountRepository.find(by: deviceOwner.address) != nil else {
                throw WalletDiagnosticServiceError.deviceKeyNotFound
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
            throw WalletDiagnosticServiceError.deviceKeyIsNotOwner
        }

        if remoteIsMissing(role: .browserExtension) || remoteIsMissing(role: .keycard) {
            throw WalletDiagnosticServiceError.twoFAIsNotOwner
        }

        if remoteIsMissing(role: .paperWallet) || remoteIsMissing(role: .paperWalletDerived) {
            throw WalletDiagnosticServiceError.paperWalletIsNotOwner
        }

        if let remoteConfirmationCount = try? proxy.getThreshold(), wallet.confirmationCount != remoteConfirmationCount {
            throw WalletDiagnosticServiceError.unexpectedSafeConfiguration
        }

        if let safeExists = try? DomainRegistry.transactionRelayService.safeExists(at: wallet.address), !safeExists {
            throw WalletDiagnosticServiceError.safeDoesNotExistInRelay
        }
    }

    func isFileAccessPossible() -> Bool {
        // the file with protection .completeUnlessOpen can be created even when the device is locked.
        // however, it cannot be read after it is closed and if the device is locked.
        // So, to check if access is possible, we'll try to read it and intercept the error.
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("detectProtection.\(UUID().uuidString)")

        let attrs = [FileAttributeKey.protectionKey: FileProtectionType.completeUnlessOpen]
        let success = FileManager.default.createFile(atPath: tempURL.path, contents: nil, attributes: attrs)
        defer { try? FileManager.default.removeItem(at: tempURL) }
        guard success else { return false }
        do {
            try _ = Data(contentsOf: tempURL)
            return true
        } catch {
            return false
        }
    }

}
