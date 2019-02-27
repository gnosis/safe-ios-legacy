//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import Common

open class OwnerModificationApplicationService: RBEStarter {

    internal var domainService: ReplaceBrowserExtensionDomainService!

    public init() {}

    open var isAvailable: Bool {
        return domainService.isAvailable
    }

    public func create() -> RBETransactionID {
        return domainService.createTransaction().id
    }

    public func estimate(transaction: RBETransactionID) -> RBEEstimationResult {
        let txID = TransactionID(transaction)
        domainService.addDummyData(to: txID)
        do {
            let fee = try domainService.estimateNetworkFee(for: txID)
            let negativeFee = TokenAmount(amount: -fee.amount, token: fee.token)
            let balance = domainService.accountBalance(for: txID)
            let remaining = domainService.resultingBalance(for: txID, change: negativeFee)
            var result = RBEEstimationResult(feeCalculation: nil, error: nil)
            result.feeCalculation =
                RBEFeeCalculationData(currentBalance: TokenData(token: balance.token, balance: balance.amount),
                                      networkFee: TokenData(token: negativeFee.token, balance: negativeFee.amount),
                                      balance: TokenData(token: remaining.token, balance: remaining.amount))
            if remaining.amount < 0 {
                result.error = FeeCalculationError.insufficientBalance
            }
            return result
        } catch let error {
            return RBEEstimationResult(feeCalculation: nil, error: error)
        }
    }

    public func start(transaction: RBETransactionID) throws {
        let txID = TransactionID(transaction)
        do {
            try domainService.validate(transactionID: txID)
        } catch ReplaceBrowserExtensionDomainServiceError.browserExtensionNotConnected {
            throw FeeCalculationError.extensionNotFound
        } catch ReplaceBrowserExtensionDomainServiceError.insufficientBalance {
            throw FeeCalculationError.insufficientBalance
        } catch ReplaceBrowserExtensionDomainServiceError.browserExtensionAlreadyExists {
            throw FeeCalculationError.extensionExists
        }
    }

    open func connect(transaction: RBETransactionID, code: String) throws {
        let txID = TransactionID(transaction)
        let newAddress = ApplicationServiceRegistry.walletService.address(browserExtensionCode: code)
        try domainService.validateNewOwnerAddress(newAddress)
        if let oldPairAddress = domainService.newOwnerAddress(from: txID) {
            try ApplicationServiceRegistry.walletService.deletePair(with: oldPairAddress)
        }
        try ApplicationServiceRegistry.walletService.createPair(from: code)
        domainService.update(transaction: txID, newOwnerAddress: newAddress)
    }

    open func startMonitoring(transaction: RBETransactionID) {
        let txID = TransactionID(transaction)
        domainService.registerPostProcessing(for: txID)
    }

}
