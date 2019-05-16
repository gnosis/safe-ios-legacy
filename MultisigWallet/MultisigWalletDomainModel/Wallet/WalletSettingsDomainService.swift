//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common
import BigInt

public class WalletSettingsDomainService {

    public init() {}

    public func isReplaceRecoveryAvailable() -> Bool {
        return DomainRegistry.walletRepository.selectedWallet()?.owner(role: .paperWallet) != nil
    }

    public func createReplaceRecoveryPhraseTransaction() -> TransactionID {
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        let accountID = AccountID(tokenID: Token.Ether.id, walletID: wallet.id)
        let tx = Transaction(id: DomainRegistry.transactionRepository.nextID(),
                             type: .replaceRecoveryPhrase,
                             walletID: wallet.id,
                             accountID: accountID)
        tx.change(sender: wallet.address!)
        let multiSendAddess = DomainRegistry.safeContractMetadataRepository.multiSendContractAddress
        tx.change(recipient: DomainRegistry.encryptionService.address(from: multiSendAddess.value)!)
        tx.change(amount: .ether(0))
        tx.change(operation: .delegateCall)
        DomainRegistry.transactionRepository.save(tx)
        return tx.id
    }

    public func estimateRecoveryPhraseTransaction(_ id: TransactionID) {
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        let tx = DomainRegistry.transactionRepository.find(id: id)!
        if tx.data == nil {
            do {
                var ownerList = OwnerLinkedList()
                let proxy = SafeOwnerManagerContractProxy(wallet.address!)
                try proxy.getOwners().forEach { ownerList.add($0) }

                let oldOwner1 = ownerList.list[1]
                let fakeNewOwner1 = Address("0x" + Data(repeating: 1, count: 20).toHexString())
                let owner1Data = proxy.swapOwner(prevOwner: ownerList.addressBefore(oldOwner1),
                                                 old: oldOwner1,
                                                 new: fakeNewOwner1)
                ownerList.replace(oldOwner1, with: fakeNewOwner1)

                let oldOwner2 = ownerList.list[2]
                let fakeNewOwner2 = Address("0x" + Data(repeating: 2, count: 20).toHexString())
                let owner2Data = proxy.swapOwner(prevOwner: ownerList.addressBefore(oldOwner2),
                                                 old: oldOwner2,
                                                 new: fakeNewOwner2)
                ownerList.replace(oldOwner2, with: fakeNewOwner2)
                let multiSendAddress = DomainRegistry.safeContractMetadataRepository.multiSendContractAddress
                let multiSendProxy = MultiSendContractProxy(multiSendAddress)
                let data = multiSendProxy.multiSend([(.call, wallet.address!, 0, owner1Data),
                                                     (.call, wallet.address!, 0, owner2Data)])


                let formattedRecipient = DomainRegistry.encryptionService.address(from: multiSendProxy.contract.value)!
                let estimationRequest = EstimateTransactionRequest(safe: wallet.address!,
                                                                   to: formattedRecipient,
                                                                   value: String(0),
                                                                   data: "0x" + data.toHexString(),
                                                                   operation: .delegateCall,
                                                                   gasToken: wallet.feePaymentTokenAddress?.value)
                let estimateResponse = try DomainRegistry
                    .transactionRelayService.estimateTransaction(request: estimationRequest)

                let (fee, estimate, nonce) = calculateFees(basedOn: estimateResponse)
                tx.change(fee: fee)
                    .change(feeEstimate: estimate)
                    .change(nonce: String(nonce))
                DomainRegistry.transactionRepository.save(tx)
            } catch let error {
                DomainRegistry.errorStream.post(error)
            }
        }
    }

    fileprivate func calculateFees(basedOn estimationResponse: EstimateTransactionRequest.Response) ->
        (TokenAmount, TransactionFeeEstimate, Int) {
            let gasPrice = TokenAmount(amount: TokenInt(estimationResponse.gasPrice), token: Token.Ether)
            let estimate = TransactionFeeEstimate(gas: estimationResponse.safeTxGas,
                                                  dataGas: estimationResponse.dataGas,
                                                  operationalGas: estimationResponse.operationalGas,
                                                  gasPrice: gasPrice)
            let fee = TokenInt(estimate.gas + estimate.dataGas) * estimate.gasPrice.amount
            let feeAmount = TokenAmount(amount: fee, token: gasPrice.token)
            return (feeAmount, estimate, estimationResponse.nextNonce)
    }

    public func isRecoveryPhraseTransactionReadyToStart(_ id: TransactionID) -> Bool {
        let tx = DomainRegistry.transactionRepository.find(id: id)!
        guard let balance = DomainRegistry.accountRepository.find(id: tx.accountID)?.balance else {
            return false
        }
        guard let estimate = tx.feeEstimate else { return false }
        let requiredBalance = estimate.totalDisplayedToUser
        return balance >= requiredBalance.amount
    }

    public func updateRecoveryPhraseTransaction(_ id: TransactionID, with newPaperWallet: Address) {
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        let walletID = wallet.id
        let tx = DomainRegistry.transactionRepository.find(id: id)!
        let newPaperEOA = DomainRegistry.externallyOwnedAccountRepository.find(by: newPaperWallet)!
        let derivedEOA = DomainRegistry.encryptionService.deriveExternallyOwnedAccount(from: newPaperEOA, at: 1)

        do {
            var ownerList = OwnerLinkedList()
            let proxy = SafeOwnerManagerContractProxy(wallet.address!)
            let remoteOwners = try proxy.getOwners()
            remoteOwners.forEach { ownerList.add($0) }

            var modifiableOwners = remoteOwners
            if let owner = wallet.owner(role: .thisDevice),
                let index = modifiableOwners.firstIndex(of: Address(owner.address.value.lowercased())) {
                modifiableOwners.remove(at: index)
            }
            if let owner = wallet.owner(role: .browserExtension),
                let index = modifiableOwners.firstIndex(of: Address(owner.address.value.lowercased())) {
                modifiableOwners.remove(at: index)
            }

            let oldOwner1 = modifiableOwners.removeFirst()
            let newOwner1 = newPaperEOA.address
            let owner1Data = proxy.swapOwner(prevOwner: ownerList.addressBefore(oldOwner1),
                                             old: oldOwner1,
                                             new: newOwner1)
            ownerList.replace(oldOwner1, with: newOwner1)

            let oldOwner2 = modifiableOwners.removeFirst()
            let newOwner2 = derivedEOA.address
            let owner2Data = proxy.swapOwner(prevOwner: ownerList.addressBefore(oldOwner2),
                                             old: oldOwner2,
                                             new: newOwner2)
            ownerList.replace(oldOwner2, with: newOwner2)

            let multiSendAddess = DomainRegistry.safeContractMetadataRepository.multiSendContractAddress
            let multiSendProxy = MultiSendContractProxy(multiSendAddess)
            let data = multiSendProxy.multiSend([(.call, wallet.address!, 0, owner1Data),
                                                 (.call, wallet.address!, 0, owner2Data)])


            let formattedRecipient = DomainRegistry.encryptionService.address(from: multiSendProxy.contract.value)!
            let estimationRequest = EstimateTransactionRequest(safe: wallet.address!,
                                                               to: formattedRecipient,
                                                               value: String(0),
                                                               data: "0x" + data.toHexString(),
                                                               operation: .delegateCall,
                                                               gasToken: wallet.feePaymentTokenAddress?.value)
            let estimateResponse = try DomainRegistry
                .transactionRelayService.estimateTransaction(request: estimationRequest)

            let (fee, estimate, nonce) = calculateFees(basedOn: estimateResponse)
            tx.change(fee: fee)
                .change(feeEstimate: estimate)
                .change(nonce: String(nonce))
                .change(data: data)
                .change(hash: DomainRegistry.encryptionService.hash(of: tx))
                .proceed()
            DomainRegistry.transactionRepository.save(tx)

            wallet.addOwner(Owner(address: newOwner1, role: .unknown))
            wallet.addOwner(Owner(address: newOwner2, role: .unknown))
            DomainRegistry.walletRepository.save(wallet)

            // FIXME: if crashes or closed before tx status finished, then wallets not updated!

            DomainRegistry.eventPublisher.subscribe(self) { [unowned self] (_: TransactionStatusUpdated) in
                guard let tx = DomainRegistry.transactionRepository.find(id: id) else {
                    DomainRegistry.eventPublisher.unsubscribe(self)
                    return
                }
                guard tx.status != .pending else { return }
                DomainRegistry.eventPublisher.unsubscribe(self)

                if tx.status == .success {
                    let wallet = DomainRegistry.walletRepository.find(id: walletID)!
                    wallet.addOwner(Owner(address: newOwner1, role: .paperWallet))
                    wallet.addOwner(Owner(address: newOwner2, role: .paperWalletDerived))
                }
                wallet.removeOwner(role: .unknown)
                DomainRegistry.walletRepository.save(wallet)

                if DomainRegistry.externallyOwnedAccountRepository.find(by: newPaperWallet) != nil {
                    DomainRegistry.externallyOwnedAccountRepository.remove(address: newPaperWallet)
                }
            }
        } catch let error {
            DomainRegistry.errorStream.post(error)
        }
    }

    public func cancelPhraseRecovery() {
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        wallet.removeOwner(role: .unknown)
        DomainRegistry.walletRepository.save(wallet)
    }

}
