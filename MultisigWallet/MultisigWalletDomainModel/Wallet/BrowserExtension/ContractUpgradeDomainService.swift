//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

open class ContractUpgradeDomainService: ReplaceBrowserExtensionDomainService {

    open override var isAvailable: Bool {
        guard let wallet = self.wallet, let masterCopy = wallet.masterCopyAddress else { return false }
        return wallet.isReadyToUse && DomainRegistry.safeContractMetadataRepository.isOldMasterCopy(address: masterCopy)
    }

    override var transactionType: TransactionType {
         return .contractUpgrade
    }

    override func dummyTransactionData() -> Data {
        return realTransactionData()
    }

    override func realTransactionData(with newAddress: String) -> Data? {
        return realTransactionData()
    }

    public func realTransactionData() -> Data {
        guard let currentAddress = DomainRegistry.walletRepository.selectedWallet()?.address else { return Data() }
        let proxy = WalletProxyContractProxy(currentAddress)
        let newAddress = DomainRegistry.safeContractMetadataRepository.latestMasterCopyAddress
        return proxy.changeMasterCopy(newAddress)
    }

    override func validateOwners() throws {
        // no owner changes - empty
    }

    open override func update(transaction: TransactionID, newOwnerAddress: String) {
        stepBackToDraft(transaction)
        let tx = self.transaction(transaction)
        tx.change(data: realTransactionData(with: newOwnerAddress))
        tx.change(hash: DomainRegistry.encryptionService.hash(of: tx))
        tx.proceed()
        repository.save(tx)
    }

    open override func postProcess(transactionID: TransactionID) throws {
        guard let tx = repository.find(id: transactionID),
            tx.type == transactionType,
            tx.status == .success || tx.status == .failed,
            let wallet = DomainRegistry.walletRepository.find(id: tx.accountID.walletID) else { return }
        guard let data = tx.data, let walletAddress = wallet.address else { return }

        let proxy = WalletProxyContractProxy(walletAddress)

        guard let newMasterCopy = proxy.decodeChangeMasterCopyArguments(from: data) else {
            return
        }

        if tx.status == .success {
            wallet.changeMasterCopy(newMasterCopy)
            let version = DomainRegistry.safeContractMetadataRepository.version(masterCopyAddress: newMasterCopy)
            wallet.changeContractVersion(version)
            DomainRegistry.walletRepository.save(wallet)
        }
        unregisterPostProcessing(for: transactionID)
    }

}
