//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common
import BigInt

public class WalletSettingsDomainService {

    public let config: RecoveryDomainServiceConfig

    public init(config: RecoveryDomainServiceConfig) {
        self.config = config
    }

    public func createReplaceRecoveryPhraseTransaction() -> TransactionID {
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        let accountID = AccountID(tokenID: Token.Ether.id, walletID: wallet.id)
        let tx = Transaction(id: DomainRegistry.transactionRepository.nextID(),
                             type: .replaceRecoveryPhrase,
                             walletID: wallet.id,
                             accountID: accountID)
        tx.change(sender: wallet.address!)
        tx.change(recipient: DomainRegistry.encryptionService.address(from: config.multiSendContractAddress.value)!)
        tx.change(amount: .ether(0))
        tx.change(operation: .delegateCall)
        DomainRegistry.transactionRepository.save(tx)
        return tx.id
    }

    public func estimateRecoveryPhraseTransaction(_ id: TransactionID) {
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        let tx = DomainRegistry.transactionRepository.findByID(id)!
        if tx.data != nil {
        } else {
            do {
                var ownerList = OwnerLinkedList()
                let proxy = SafeOwnerManagerContractProxy(wallet.address!)
                try proxy.getOwners().forEach { ownerList.add($0) }

                let oldOwner1 = wallet.owner(role: .paperWallet)!
                let fakeNewOwner1 = Address("0x" + Data(repeating: 1, count: 20).toHexString())
                let owner1Data = proxy.swapOwner(prevOwner: ownerList.addressBefore(oldOwner1),
                                             old: oldOwner1.address,
                                             new: fakeNewOwner1)
                ownerList.replace(oldOwner1.address, with: fakeNewOwner1)

                let oldOwner2 = wallet.owner(role: .paperWalletDerived)!
                let fakeNewOwner2 = Address("0x" + Data(repeating: 2, count: 20).toHexString())
                let owner2Data = proxy.swapOwner(prevOwner: ownerList.addressBefore(oldOwner2),
                                                 old: oldOwner2.address,
                                                 new: fakeNewOwner2)
                ownerList.replace(oldOwner2.address, with: fakeNewOwner2)

                let multiSendProxy = MultiSendContractProxy(config.multiSendContractAddress)
                let data = multiSendProxy.multiSend([(.call, wallet.address!, 0, owner1Data),
                                                     (.call, wallet.address!, 0, owner2Data)])


                let formattedRecipient = DomainRegistry.encryptionService.address(from: multiSendProxy.contract.value)!
                let estimationRequest = EstimateTransactionRequest(safe: wallet.address!,
                                                                   to: formattedRecipient,
                                                                   value: String(0),
                                                                   data: "0x" + data.toHexString(),
                                                                   operation: .delegateCall)
                let estimateResponse = try DomainRegistry.transactionRelayService.estimateTransaction(request: estimationRequest)

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
        let tx = DomainRegistry.transactionRepository.findByID(id)!
        guard let balance = DomainRegistry.accountRepository.find(id: tx.accountID)?.balance else {
            return false
        }
        guard let estimate = tx.feeEstimate else { return false }
        let requiredBalance = estimate.total
        return balance >= requiredBalance.amount
    }

}
