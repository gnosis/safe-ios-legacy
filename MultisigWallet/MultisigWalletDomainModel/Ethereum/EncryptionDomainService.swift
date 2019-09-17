//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

/// Ethereum transaction data structure
public typealias EthTransaction = (from: String, value: Int, data: String, gas: String, gasPrice: String, nonce: Int)

/// Raw Ethereum transaction data structure
public typealias EthRawTransaction =
    (to: String, value: Int, data: String, gas: String, gasPrice: String, nonce: Int)

/// Interface for different operations performed with addresses, signatures and hashes
public protocol EncryptionDomainService {

    /// Generates new random externally owned account
    ///
    /// - Returns: random externally owned account
    func generateExternallyOwnedAccount() -> ExternallyOwnedAccount

    func deriveExternallyOwnedAccount(from mnemonic: String) -> ExternallyOwnedAccount?

    /// Derives externally owned account from existing account at the specified derivation path index
    ///
    /// - Parameters:
    ///   - account: account to derive from
    ///   - pathIndex: path index of the derived account
    /// - Returns: derived account
    func deriveExternallyOwnedAccount(from account: ExternallyOwnedAccount, at pathIndex: Int) -> ExternallyOwnedAccount

    /// Converts browser extension code string to Ethereum address, verifying code validity and sender's signature.
    ///
    /// - Parameter browserExtensionCode: code received from browser extension owner
    /// - Returns: address if code is valid, nil otherwise.
    func address(browserExtensionCode: String) -> String?

    /// Derives contract address from the transaction created the contract and signature of the transaction sender.
    ///
    /// - Parameters:
    ///   - from: signature of sender
    ///   - transaction: transaction that creates the contract
    /// - Returns: contract address, or nil if signature-transaction pair is invalid
    func contractAddress(from: EthSignature, for transaction: EthTransaction) -> String?

    /// Generates random number for safe creation transaction
    ///
    /// - Returns: valid random uint256 value
    func randomSaltNonce() -> BigUInt

    /// Signs string data using the private key.
    ///
    /// - Parameters:
    ///   - message: data to sign
    ///   - privateKey: private key to sign
    /// - Returns: signature of the message
    func sign(message: String, privateKey: PrivateKey) -> EthSignature

    /// Converts between Signature and EthSignature data structures
    ///
    /// - Parameter signature: signature to convert to r,s,v format
    /// - Returns: EthSignature with r,s,v
    func ethSignature(from signature: Signature) -> EthSignature

    /// Hashes transaction data, according to ERC191
    ///
    /// - Parameter transaction: transaction to hash
    /// - Returns: hash of the transaction data
    func hash(of transaction: Transaction) -> Data

    /// Hashes data with keccak's sha3 256
    ///
    /// - Parameter data: data to hash
    /// - Returns: 32-byte hash of the data
    func hash(_ data: Data) -> Data

    /// Recovers the Ethereum address from 32-byte hash and signature
    ///
    /// - Parameters:
    ///   - hash: hash to use for address recovery
    ///   - signature: signature of the hash
    /// - Returns: address if signature is valid, nil otherwise
    func address(hash: Data, signature: EthSignature) -> String?

    /// Converts EthSignature to Data
    ///
    /// - Parameter signature: signature to convert
    /// - Returns: data value
    func data(from signature: EthSignature) -> Data

    /// Signs transaction's hash with private key and returns the signature.
    ///
    /// - Parameters:
    ///   - transaction: transaction to sign
    ///   - privateKey: private key to sign
    /// - Returns: transaction signature
    func sign(transaction: Transaction, privateKey: PrivateKey) -> Data

    /// Returns checksummed address from non-checksummed address
    ///
    /// - Parameter string: address string
    /// - Returns: address data structure or nil if the address string is invalid.
    func address(from string: String) -> Address?

    /// Returns checksummed address from a public key data
    func address(publicKey: Data) -> Address

    /// Recovers address from the ECDSA signature and hash
    func recoveredAddress(from signature: Data, hash: Data) -> Address?

}
