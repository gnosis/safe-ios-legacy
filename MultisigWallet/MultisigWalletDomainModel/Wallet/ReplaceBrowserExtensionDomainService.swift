//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public enum ReplaceBrowserExtensionDomainServiceError: Error {
    case insufficientBalance
    case browserExtensionNotConnected
}

public class ReplaceBrowserExtensionDomainService: Assertable {

    public var isAvailable: Bool {
        guard let wallet = self.wallet else { return false }
        return wallet.owner(role: .browserExtension) != nil
    }

    public var ownerContractProxy: SafeOwnerManagerContractProxy?

    private var wallet: Wallet? {
        return DomainRegistry.walletRepository.selectedWallet()
    }

    private var requiredWallet: Wallet {
        return wallet!
    }

    private var repository: TransactionRepository {
        return DomainRegistry.transactionRepository
    }

    public init() {}

    // MARK: - Transaction Creation and Validation

    public func createTransaction() -> TransactionID {
        let tx = Transaction(id: repository.nextID(),
                             type: .replaceBrowserExtension,
                             walletID: requiredWallet.id,
                             accountID: AccountID(tokenID: Token.Ether.id, walletID: requiredWallet.id))
        tx.change(amount: .ether(0)).change(sender: requiredWallet.address!)
        repository.save(tx)
        return tx.id
    }

    public func deleteTransaction(id: TransactionID) {
        repository.remove(transaction(id))
    }

    public func addDummyData(to transactionID: TransactionID) {
        let tx = transaction(transactionID)
        tx.change(recipient: wallet!.address!).change(operation: .call).change(data: dummySwapData())
        repository.save(tx)
    }

    func dummySwapData() -> Data {
        let proxy = ownerContractProxy ?? SafeOwnerManagerContractProxy(self.wallet!.address!)
        var remoteList = OwnerLinkedList()
        if let owners = try? proxy.getOwners(), !owners.isEmpty {
            owners.forEach { remoteList.add($0) }
            let toSwap = owners.first!
            let prev = remoteList.addressBefore(toSwap)
            let data = proxy.swapOwner(prevOwner: prev, old: toSwap, new: self.wallet!.address!)
            return data
        }
        remoteList.add(.zero)
        return proxy.swapOwner(prevOwner: remoteList.addressBefore(.one), old: .zero, new: .zero)
    }

    public func removeDummyData(from transactionID: TransactionID) {
        let tx = transaction(transactionID)
        tx.change(recipient: nil).change(operation: nil).change(data: nil)
        repository.save(tx)
    }

    public func estimateNetworkFee(for transactionID: TransactionID) throws -> TokenAmount {
        let tx = transaction(transactionID)
        let request = estimationRequest(for: tx)
        let response = try DomainRegistry.transactionRelayService.estimateTransaction(request: request)
        let userFacingFee = TokenInt((response.dataGas + response.safeTxGas + response.operationalGas) *
            response.gasPrice)
        let transactionFee = TokenInt((response.dataGas + response.safeTxGas) * response.gasPrice)
        let token = Token.Ether
        tx.change(fee: TokenAmount(amount: transactionFee, token: token))
        let estimate = TransactionFeeEstimate(gas: response.safeTxGas,
                                              dataGas: response.dataGas,
                                              operationalGas: response.operationalGas,
                                              gasPrice: TokenAmount(amount: TokenInt(response.gasPrice), token: token))
        tx.change(feeEstimate: estimate)
        repository.save(tx)
        return .ether(userFacingFee)
    }

    private func estimationRequest(for tx: Transaction) -> EstimateTransactionRequest {
        return .init(safe: tx.sender!,
                     to: tx.ethTo,
                     value: String(tx.ethValue),
                     data: tx.ethData,
                     operation: tx.operation!)
    }

    public func accountBalance(for transactionID: TransactionID) -> TokenAmount {
        let tx = transaction(transactionID)
        let account = DomainRegistry.accountRepository.find(id: tx.accountID)!
        let balance = account.balance ?? 0
        return .ether(balance)
    }

    public func resultingBalance(for transactionID: TransactionID, change amount: TokenAmount) -> TokenAmount {
        let balance = accountBalance(for: transactionID)
        let newBalance = TokenAmount(amount: balance.amount + amount.amount, token: balance.token)
        return newBalance
    }

    public func validate(transactionID: TransactionID) throws {
        let tx = transaction(transactionID)
        precondition(tx.fee != nil, "fee must be set during estimation")
        precondition(tx.feeEstimate != nil, "fee estimate must be set during estimation")
        let totalFeeAmount = -TokenInt(tx.feeEstimate!.dataGas + tx.feeEstimate!.gas + tx.feeEstimate!.operationalGas) *
            tx.feeEstimate!.gasPrice.amount
        let totalFee = TokenAmount(amount: totalFeeAmount, token: tx.feeEstimate!.gasPrice.token)
        try assertTrue(resultingBalance(for: transactionID, change: totalFee).amount >= 0,
                       ReplaceBrowserExtensionDomainServiceError.insufficientBalance)
        try assertNotNil(requiredWallet.owner(role: .browserExtension) ,
                         ReplaceBrowserExtensionDomainServiceError.browserExtensionNotConnected)
    }

    private func transaction(_ id: TransactionID, file: StaticString = #file, line: UInt = #line) -> Transaction {
        guard let tx = repository.findByID(id) else {
            preconditionFailure("transaction not found \(file):\(line)")
        }
        return tx
    }

    // MARK: - Connection of Browser Extension

    public func newOwnerAddress(from transactionID: TransactionID) -> String? {
        let proxy = ownerContractProxy ?? SafeOwnerManagerContractProxy(self.wallet!.address!)
        let tx = self.transaction(transactionID)
        guard let data = tx.data, let arguments = proxy.decodeSwapOwnerArguments(from: data) else { return nil }
        return arguments.new.value
    }

    public func update(transaction: TransactionID, newOwnerAddress: String) {
        let tx = self.transaction(transaction)
        tx.change(data: swapOwnerData(with: newOwnerAddress))
        repository.save(tx)
    }

    func swapOwnerData(with newAddress: String) -> Data? {
        let proxy = ownerContractProxy ?? SafeOwnerManagerContractProxy(self.wallet!.address!)
        var linkedList = OwnerLinkedList()
        guard let remoteOwners = try? proxy.getOwners(), !remoteOwners.isEmpty else { return nil }
        remoteOwners.forEach { linkedList.add($0) }
        let extensionAddress = wallet!.owner(role: .browserExtension)!.address
        guard linkedList.contains(extensionAddress) else { return nil }
        let prev = linkedList.addressBefore(extensionAddress)
        let data = proxy.swapOwner(prevOwner: prev, old: extensionAddress, new: Address(newAddress))
        return data
    }

}
