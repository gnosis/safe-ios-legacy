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
        tx.change(recipient: wallet!.address!).change(operation: .delegateCall).change(data: dummySwapData())
        repository.save(tx)
    }

    func dummySwapData() -> Data {
        let proxy = ownerContractProxy ?? SafeOwnerManagerContractProxy(self.wallet!.address!)
        var dummyList = OwnerLinkedList()
        dummyList.add(.zero)
        return proxy.swapOwner(prevOwner: dummyList.addressBefore(.zero), old: .zero, new: .zero)
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
        let fee = TokenInt((response.dataGas + response.safeTxGas + response.operationalGas) * response.gasPrice)
        let token = Token.Ether
        tx.change(fee: TokenAmount(amount: TokenInt(response.dataGas + response.safeTxGas), token: token))
        let estimate = TransactionFeeEstimate(gas: response.safeTxGas,
                                              dataGas: response.dataGas,
                                              operationalGas: response.operationalGas,
                                              gasPrice: TokenAmount(amount: TokenInt(response.gasPrice), token: token))
        tx.change(feeEstimate: estimate)
        return .ether(fee)
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

}
