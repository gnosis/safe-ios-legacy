//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Intermediate service that sends transactions to the blockchain.
public protocol TransactionRelayDomainService {

    /// Creates a new transaction waiting for enough funds on the future safe's address.
    ///
    /// - Parameter request: parameters for the new safe
    /// - Returns: creation arguments from which to derive safe address
    /// - Throws: network error or request error
    func createSafeCreationTransaction(request: SafeCreationRequest) throws -> SafeCreationRequest.Response

    /// Starts safe deployment. Safe must have enough funds for transaction deployment.
    ///
    /// - Parameter address: safe address
    /// - Throws: network error or server error
    func startSafeCreation(address: Address) throws

    /// Checks whether Ethereum transaction of contract deployment is available
    ///
    /// - Parameter address: address of the deployed safe
    /// - Returns: transaction hash if available, nil otherwise
    /// - Throws: network or server error
    func safeCreationTransactionHash(address: Address) throws -> TransactionHash?

    /// Fetches current gas price
    ///
    /// - Returns: gas price response
    /// - Throws: network error or server error
    func gasPrice() throws -> SafeGasPriceResponse

    /// Submit transaction to Blockchain
    ///
    /// - Parameter request: transaction information to submit
    /// - Returns: transaction hash
    /// - Throws: network error, or server error
    func submitTransaction(request: SubmitTransactionRequest) throws -> SubmitTransactionRequest.Response

    /// Estimates fees for a transaction
    ///
    /// - Parameter request: transaction information
    /// - Returns: fee estimation
    /// - Throws: network error, or server error
    func estimateTransaction(request: EstimateTransactionRequest) throws -> EstimateTransactionRequest.Response

}
