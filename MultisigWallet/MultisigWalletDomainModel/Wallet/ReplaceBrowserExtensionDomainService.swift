//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public class ReplaceBrowserExtensionDomainService {

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
        return .ether(0)
    }

    public func accountBalance(for transactionID: TransactionID) -> TokenAmount {
        preconditionFailure()
    }

    public func resultingBalance(for transactionID: TransactionID, change amount: TokenAmount) -> TokenAmount {
        preconditionFailure()
    }

    // validate transaction
    //      network fee must be estimated
    //      network fee account must exist -> wallet must exist
    //      validate balance
    //          network fee balance >= network fee amount
    //          otherwise return error
    //      validate contract
    //          remote master copy address
    //          locally, safe scheme must be 2 / 4
    public func validate(transactionID: TransactionID) -> Error? {
        preconditionFailure()
    }

    private func transaction(_ id: TransactionID, file: StaticString = #file, line: UInt = #line) -> Transaction {
        guard let tx = repository.findByID(id) else {
            preconditionFailure("transaction not found \(file):\(line)")
        }
        return tx
    }

}
