//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

open class ConnectTwoFADomainService: ReplaceTwoFADomainService {

    open override var isAvailable: Bool {
        guard let wallet = self.wallet else { return false }
        return wallet.isReadyToUse && !wallet.hasAuthenticator
    }

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
        try assertFalse(requiredWallet.hasAuthenticator, ReplaceTwoFADomainServiceError.twoFAAlreadyExists)
    }

    override func realTransactionData(with newAddress: String) -> Data? {
        return contractProxy.addOwner(Address(newAddress), newThreshold: 2)
    }

    override func processSuccess(tx: Transaction, with newOwner: String, in wallet: Wallet) throws {
        let role = tx.type.correspondingOwnerRole!
        add(newOwner: newOwner, role: role, to: wallet)
        wallet.changeConfirmationCount(2)
        DomainRegistry.walletRepository.save(wallet)
        try? DomainRegistry.communicationService.notifyWalletCreatedIfNeeded(walletID: wallet.id)        
    }

    override func processFailure(tx: Transaction, walletID: WalletID, newOwnerAddress: String) throws {
        if tx.type == .connectAuthenticator {
            try DomainRegistry.communicationService.deletePair(walletID: walletID, other: newOwnerAddress)
        }
    }

}
