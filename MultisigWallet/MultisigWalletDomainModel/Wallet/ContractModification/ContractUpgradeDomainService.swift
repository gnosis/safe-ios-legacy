//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public class ContractUpgraded: DomainEvent {}

/// the latest upgrade is to version 1.1.1
open class ContractUpgradeDomainService: ReplaceTwoFADomainService {

    lazy var multiSendProxy: MultiSendContractProxy = {
        let multiSendAddress = DomainRegistry.safeContractMetadataRepository.multiSendContractAddress
        return MultiSendContractProxy(multiSendAddress)
    }()

    open override var isAvailable: Bool {
        guard let wallet = self.wallet, wallet.isReadyToUse, wallet.hasWritePermission else { return false }
        guard let masterCopy = wallet.masterCopyAddress else {
            // old safes created long time ago don't have the masterCopy property set, so we want to upgrade them.
            return true
        }
        return DomainRegistry.safeContractMetadataRepository.isOldMasterCopy(address: masterCopy)
    }

    // all data is known upfront.
    public override func createTransaction() -> TransactionID {
        let txID = super.createTransaction()
        let tx = transaction(txID)
        let checksumedRecepient = DomainRegistry.encryptionService.address(from: multiSendProxy.contract.value)!
        tx.change(type: .contractUpgrade)
            .change(recipient: checksumedRecepient)
            .change(operation: .delegateCall)
            .change(data: realTransactionData())
        repository.save(tx)
        return txID
    }

    public override func addDummyData(to transactionID: TransactionID) { /* do nothing */ }

    func realTransactionData() -> Data {
        guard let currentAddress = DomainRegistry.walletRepository.selectedWallet()?.address else { return Data() }
        let proxy = GnosisSafeContractProxy(currentAddress)

        let newAddress = DomainRegistry.safeContractMetadataRepository.latestMasterCopyAddress
        let changeMasterCopyData = proxy.changeMasterCopy(newAddress)

        let fallbackHandler = DomainRegistry.safeContractMetadataRepository.fallbackHandlerAddress
        let setFallbackHandlerData = proxy.setFallbackHandler(address: fallbackHandler)

        return multiSendProxy.multiSend([
            (operation: .call, to: currentAddress, value: 0, data: changeMasterCopyData),
            (operation: .call, to: currentAddress, value: 0, data: setFallbackHandlerData)])
    }

    override func validateOwners() throws { /* no owner changes - empty */ }

    open override func update(transaction: TransactionID, newOwnerAddress: String) {
        stepBackToDraft(transaction) // changes status only
        let tx = self.transaction(transaction)
        tx.change(hash: DomainRegistry.encryptionService.hash(of: tx))
        tx.proceed()
        repository.save(tx)
    }

    open override func postProcess(transactionID: TransactionID) throws {
        guard let tx = repository.find(id: transactionID),
            tx.type == .contractUpgrade,
            tx.status == .success || tx.status == .failed,
            let wallet = DomainRegistry.walletRepository.find(id: tx.accountID.walletID) else { return }
        guard let data = tx.data, let walletAddress = wallet.address else { return }

        let proxy = GnosisSafeContractProxy(walletAddress)
        guard let multisendTransactions = multiSendProxy.decodeMultiSendArguments(from: data),
            let changeMasterCopyData = multisendTransactions.first?.data,
            let newMasterCopy = proxy.decodeChangeMasterCopyArguments(from: changeMasterCopyData) else { return }

        if tx.status == .success {
            wallet.changeMasterCopy(newMasterCopy)
            let version = DomainRegistry.safeContractMetadataRepository.version(masterCopyAddress: newMasterCopy)
            wallet.changeContractVersion(version)
            DomainRegistry.walletRepository.save(wallet)
            DomainRegistry.eventPublisher.publish(ContractUpgraded())
        }
        unregisterPostProcessing(for: transactionID)
    }

}
