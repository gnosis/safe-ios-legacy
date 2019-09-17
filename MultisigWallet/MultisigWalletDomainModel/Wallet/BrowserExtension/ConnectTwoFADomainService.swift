//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

open class ConnectTwoFADomainService: ReplaceTwoFADomainService {

    open override var isAvailable: Bool {
        guard let wallet = self.wallet else { return false }
        let twoFAIsNotConnected = wallet.owner(role: .browserExtension) == nil &&
            wallet.owner(role: .keycard) == nil
        return wallet.isReadyToUse && twoFAIsNotConnected
    }

    private var _transactionType: TransactionType = .connectAuthenticator

    override var transactionType: TransactionType { return _transactionType }

    override var postProcessTypes: [TransactionType] {
        return [.connectAuthenticator, .connectStatusKeycard]
    }

    override func dummyTransactionData() -> Data {
        let dummyAddress: Address = wallet?.address ?? .two
        return contractProxy.addOwner(dummyAddress, newThreshold: 2)
    }

    open override func newOwnerAddress(from transactionID: TransactionID) -> String? {
        let tx = self.transaction(transactionID)
        guard let data = tx.data, let arguments = contractProxy.decodeAddOwnerArguments(from: data) else { return nil }
        return arguments.new.value
    }

    override func validateOwners() throws {
        try assertNil(requiredWallet.owner(role: .browserExtension),
                      ReplaceTwoFADomainServiceError.twoFAAlreadyExists)
        try assertNil(requiredWallet.owner(role: .keycard),
                      ReplaceTwoFADomainServiceError.twoFAAlreadyExists)
    }

    override func realTransactionData(with newAddress: String) -> Data? {
        return contractProxy.addOwner(Address(newAddress), newThreshold: 2)
    }

    override func processSuccess(with newOwner: String, in wallet: Wallet) throws {
        var role: OwnerRole!
        switch transactionType {
        case .connectAuthenticator: role = .browserExtension
        case .connectStatusKeycard: role = .keycard
        default: preconditionFailure("Wrong usage of ConnectTwoFADomainService")
        }
        add(newOwner: newOwner, role: role, to: wallet)
        wallet.changeConfirmationCount(2)
        DomainRegistry.walletRepository.save(wallet)
        if transactionType == .connectAuthenticator {
            try? DomainRegistry.communicationService.notifyWalletCreated(walletID: wallet.id)
        }
    }

    override func processFailure(walletID: WalletID, newOwnerAddress: String) throws {
        if transactionType == .connectAuthenticator {
            try DomainRegistry.communicationService.deletePair(walletID: walletID, other: newOwnerAddress)
        }
    }

}
