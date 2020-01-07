//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
@testable import safe
import MultisigWalletDomainModel
import MultisigWalletImplementations
import BigInt
import Common
import CryptoSwift
import CommonTestSupport

struct Safe {

    var creationFee: TokenInt!
    var address: Address!
    var confirmations: Int
    var owners: [ExternallyOwnedAccount]
    let walletID: WalletID

    init(owners: [ExternallyOwnedAccount], confirmations: Int) {
        self.confirmations = confirmations
        self.owners = owners

        let repo = DomainRegistry.walletRepository
        // create owner list with max 4 owners
        var roles = [OwnerRole.thisDevice, .browserExtension, .paperWallet, .paperWalletDerived]
        var eoas = self.owners
        var ownerList = [Owner]()
        while !roles.isEmpty && !eoas.isEmpty {
            let eoa = eoas.removeFirst()
            let role = roles.removeFirst()
            ownerList.append(Wallet.createOwner(address: eoa.address.value, role: role))
        }
        let wallet = Wallet(id: repo.nextID(),
                            state: .deploying,
                            owners: OwnerList(ownerList),
                            address: nil,
                            feePaymentTokenAddress: nil,
                            minimumDeploymentTransactionAmount: nil,
                            creationTransactionHash: nil,
                            confirmationCount: confirmations,
                            masterCopyAddress: nil,
                            contractVersion: nil)
        repo.save(wallet)
        walletID = wallet.id
    }

    var _test: HTTPGnosisTransactionRelayServiceTests!

    var gasAdjustment: BigInt = 0

    var proxy: SafeOwnerManagerContractProxy { return SafeOwnerManagerContractProxy(address) }

    func prepareAddOwnerTx(_ owner: ExternallyOwnedAccount, threshold: Int) throws -> Transaction {
        let data = proxy.addOwner(owner.address, newThreshold: threshold)
        return try prepareTx(to: address, data: data, feePaymentToken: Token.Ether)
    }

    func prepareTx(to recipient: Address,
                   amount: TokenInt = 0,
                   data: Data? = nil,
                   operation: WalletOperation = .call,
                   type: TransactionType = .transfer,
                   feePaymentToken: Token = Token.Ether) throws -> Transaction {
        let request = EstimateTransactionRequest(safe: address,
                                                 to: recipient,
                                                 value: String(amount),
                                                 data: data == nil ? "" : data!.toHexString().addHexPrefix(),
                                                 operation: operation,
                                                 gasToken: feePaymentToken.address.value)
        let response = try _test.relayService.estimateTransaction(request: request)
        // Gas is adjusted because server-side gas estimate is
        // inherently inaccurate: (dataGas + txGas) is not enough for funding the fees.
        let fee = (response.baseGas.value + response.safeTxGas.value + response.operationalGas.value +
            gasAdjustment) * response.gasPrice.value
        let nonce = response.nextNonce
        let tx = Transaction(id: TransactionID(),
                             type: type,
                             accountID: AccountID(tokenID: Token.Ether.id, walletID: walletID))
        tx.change(sender: address)
            .change(feeEstimate: TransactionFeeEstimate(gas: response.safeTxGas.value,
                                                        dataGas: response.baseGas.value,
                                                        operationalGas: response.operationalGas.value,
                                                        gasPrice: TokenAmount(amount: response.gasPrice.value,
                                                                              token: feePaymentToken)))
            .change(fee: TokenAmount(amount: fee, token: feePaymentToken))
            .change(nonce: String(nonce))
            .change(recipient: recipient)
            .change(data: data)
            .change(amount: TokenAmount(amount: amount, token: Token.Ether))
            .change(operation: operation)
            .change(hash: _test.encryptionService.hash(of: tx))
            .proceed()
        return tx
    }

    func deploy() throws {
        let balance = try _test.infuraService.eth_getBalance(account: address)
        assert(balance >= creationFee)
        try _test.relayService.startSafeCreation(address: address)
        let tx = try _test.waitForSafeCreationTransaction(address)
        let reciept = try _test.waitForTransaction(tx)!
        assert(reciept.status == .success)
        let proxy = GnosisSafeContractProxy(address)
        let wallet = DomainRegistry.walletRepository.find(id: walletID)!
        wallet.changeAddress(address)
        try wallet.changeMasterCopy(proxy.masterCopyAddress())
        // changing of certain properties is possible only in readyToUse state
        wallet.state = wallet.readyToUseState
        DomainRegistry.walletRepository.save(wallet)
    }

    func sign(_ tx: Transaction, by account: ExternallyOwnedAccount) {
        let sigData = _test.encryptionService.sign(transaction: tx, privateKey: account.privateKey)
        tx.add(signature: Signature(data: sigData, address: account.address))
    }

    func executeTransaction(_ tx: Transaction) throws {
        try submit(transaction: tx)
        let receipt = try _test.waitForTransaction(tx.transactionHash!)!
        assert(receipt.status == .success)
    }

    func submit(transaction tx: Transaction) throws {
        let sortedSigs = tx.signatures.sorted { $0.address.value.lowercased() < $1.address.value.lowercased() }
        let ethSigs = sortedSigs.map { _test.encryptionService.ethSignature(from: $0) }
        let request = SubmitTransactionRequest(transaction: tx, signatures: ethSigs)
        let response = try _test.relayService.submitTransaction(request: request)
        let hash = TransactionHash(response.transactionHash)
        tx.set(hash: hash).proceed()
    }

    func isOwner(_ address: Address) throws -> Bool {
        let proxy = SafeOwnerManagerContractProxy(self.address)
        return try proxy.isOwner(address)
    }

    func getThreshold() throws -> Int {
        let proxy = SafeOwnerManagerContractProxy(address)
        return try proxy.getThreshold()
    }

}
