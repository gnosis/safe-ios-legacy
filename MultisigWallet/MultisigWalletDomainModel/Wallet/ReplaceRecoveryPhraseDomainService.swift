//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public enum ReplaceRecoveryPhraseDomainServiceError: String, Error {
    case missingRecoveryOwner
    case missingDerivedRecoveryAddress
}

public class ReplaceRecoveryPhraseDomainService: ReplaceBrowserExtensionDomainService {

    var multiSendProxy: MultiSendContractProxy {
        let multiSendAddress = DomainRegistry.safeContractMetadataRepository.multiSendContractAddress
        return MultiSendContractProxy(multiSendAddress)
    }

    public override var isAvailable: Bool {
        guard let wallet = self.wallet else { return false }
        return wallet.isReadyToUse && wallet.owner(role: .paperWallet) != nil
    }

    override var transactionType: TransactionType {
        return .replaceRecoveryPhrase
    }

    public override func addDummyData(to transactionID: TransactionID) {
        let tx = transaction(transactionID)
        let recipient = DomainRegistry.safeContractMetadataRepository.multiSendContractAddress
        let formattedRecipient = formatted(recipient)!
        tx.change(recipient: formattedRecipient)
            .change(operation: .delegateCall)
            .change(data: dummyTransactionData())
        repository.save(tx)

    }

    private func formatted(_ address: Address) -> Address? {
        return DomainRegistry.encryptionService.address(from: address.value)
    }

    override func dummyTransactionData() -> Data {
        var list: OwnerLinkedList
        var old: [Address]
        let new: [Address] = [.two, .three]

        if let remoteList = remoteOwnersList(),
            let remoteAddress1 = remoteList.firstAddress(),
            let remoteAddress2 = remoteList.addressAfter(remoteAddress1) {
            list = remoteList
            old = [remoteAddress1, remoteAddress2]
        } else {
            list = OwnerLinkedList()
            list.add(.two)
            list.add(.three)
            old = [.two, .three]
        }
        return transactionData(list: list, old: old, new: new)!
    }

    private func transactionData(list: OwnerLinkedList, old: [Address], new: [Address]) -> Data? {
        guard old.count == new.count else { return nil }
        let walletAddress = requiredWallet.address!
        var list = list
        var transactions = [MultiSendTransaction]()
        for index in (0..<old.count) {
            let data = contractProxy.swapOwner(prevOwner: list.addressBefore(old[index]),
                                               old: old[index],
                                               new: new[index])
            list.replace(old[index], with: new[index])
            transactions.append((.call, walletAddress, 0, data))
        }
        let multiSendAddress = DomainRegistry.safeContractMetadataRepository.multiSendContractAddress
        let multiSendProxy = MultiSendContractProxy(multiSendAddress)
        return multiSendProxy.multiSend(transactions)
    }

    public override func update(transaction: TransactionID, newOwnerAddress: String) {
        super.update(transaction: transaction, newOwnerAddress: newOwnerAddress)
        let tx = self.transaction(transaction)
        tx.change(operation: .delegateCall)
        repository.save(tx)
    }

    override func realTransactionData(with newAddress: String) -> Data? {
        guard let list = remoteOwnersList() else { return nil }

        let readOnlyOwners = [requiredWallet.owner(role: .thisDevice),
                              requiredWallet.owner(role: .browserExtension),
                              requiredWallet.owner(role: .keycard)]
            .compactMap { $0 }
            .map { Address($0.address.value.lowercased()) }

        let modifiableOwners = Array(Set(list.contents).subtracting(Set(readOnlyOwners)))
        guard modifiableOwners.count >= 2 else { return nil }

        guard let newOwner1 = DomainRegistry.externallyOwnedAccountRepository.find(by: Address(newAddress)) else {
            return nil
        }
        let newOwner2 = DomainRegistry.encryptionService.deriveExternallyOwnedAccount(from: newOwner1, at: 1)

        return transactionData(list: list,
                               old: Array(modifiableOwners.prefix(2)),
                               new: [newOwner1, newOwner2].map { $0.address })
    }

    override func validateOwners() throws {
        try assertNotNil(requiredWallet.owner(role: .paperWallet),
                         ReplaceRecoveryPhraseDomainServiceError.missingRecoveryOwner)
        try assertNotNil(requiredWallet.owner(role: .paperWalletDerived),
                         ReplaceRecoveryPhraseDomainServiceError.missingDerivedRecoveryAddress)
    }

    public override func postProcess(transactionID: TransactionID) throws {
        guard let tx = repository.find(id: transactionID),
            tx.type == transactionType,
            tx.status == .success || tx.status == .failed,
            let wallet = DomainRegistry.walletRepository.find(id: tx.accountID.walletID) else { return }
        guard let data = tx.data,
            let transactions = multiSendProxy.decodeMultiSendArguments(from: data),
            transactions.count >= 2,
            let swap1 = contractProxy.decodeSwapOwnerArguments(from: transactions[0].data),
            let swap2 = contractProxy.decodeSwapOwnerArguments(from: transactions[1].data),
            let newOwner1 = formatted(swap1.new),
            let newOwner2 = formatted(swap2.new) else {
                return
        }
        if tx.status == .success {
            wallet.addOrReplaceOwner(Owner(address: newOwner1, role: .paperWallet))
            wallet.addOrReplaceOwner(Owner(address: newOwner2, role: .paperWalletDerived))
            DomainRegistry.walletRepository.save(wallet)
        }

        if DomainRegistry.externallyOwnedAccountRepository.find(by: newOwner1) != nil {
            DomainRegistry.externallyOwnedAccountRepository.remove(address: newOwner1)
        }

        unregisterPostProcessing(for: transactionID)
    }

}
