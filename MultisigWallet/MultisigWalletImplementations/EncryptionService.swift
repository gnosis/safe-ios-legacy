//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import MultisigWalletApplication
import EthereumKit
import Common
import CryptoSwift
import BigInt

// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-155.md
public enum EIP155ChainId: Int {
    case mainnet = 1
    case morden = 2
    case ropsten = 3
    case rinkeby = 4
    case rootstockMainnet = 30
    case rootstockTestnet = 31
    case kovan = 42
    case ethereumClassicMainnet = 61
    case ethereumClassicTestnet = 62
    case gethPrivateChains = 1_337
    case any = 0
}

struct ExtensionCode {

    let expirationDate: String
    let v: BInt
    let r: BInt
    let s: BInt

    init?(json: Any) {
        guard let json = json as? [String: Any],
            let expirationDate = json["expirationDate"] as? String,
            let signature = json["signature"] as? [String: Any],
            let vInt = signature["v"] as? Int,
            let rStr = signature["r"] as? String,
            let r = BInt(rStr, radix: 10), // FIXME: crashes on iOS 10.0
            let sStr = signature["s"] as? String,
            let s = BInt(sStr, radix: 10)
            else { return nil }
        self.expirationDate = expirationDate
        self.v = BInt(vInt)
        self.r = r
        self.s = s
    }

}

public protocol EthereumService: Assertable {

    func createMnemonic() -> [String]
    func createSeed(mnemonic: [String]) -> Data
    func createPrivateKey(seed: Data, network: EIP155ChainId) -> Data
    func createPublicKey(privateKey: Data) -> Data
    func createAddress(publicKey: Data) -> String

}

public enum EthereumServiceError: String, LocalizedError, Hashable {
    case invalidMnemonicWordsCount
}

public extension EthereumService {

    func createExternallyOwnedAccount(chainId: EIP155ChainId) throws ->
        (mnemonic: [String], privateKey: Data, publicKey: Data, address: String) {
        let words = createMnemonic()
        try assertEqual(words.count, 12, EthereumServiceError.invalidMnemonicWordsCount)
        let seed = createSeed(mnemonic: words)
        let privateKey = createPrivateKey(seed: seed, network: chainId)
        let publicKey = createPublicKey(privateKey: privateKey)
        let address = createAddress(publicKey: publicKey)
        return (words, privateKey, publicKey, address)
    }
}

open class EncryptionService: EncryptionDomainService {

    public enum Error: String, LocalizedError, Hashable {
        case failedToGenerateAccount
        case invalidTransactionData
        case invalidSignature
        case invalidCodeJSON
        case invalidString
    }

    let chainId: EIP155ChainId
    let ethereumService: EthereumService
    private let signer: EIP155Signer

    public init(chainId: EIP155ChainId = .any, ethereumService: EthereumService = EthereumKitEthereumService()) {
        self.chainId = chainId
        self.ethereumService = ethereumService
        self.signer = EIP155Signer(chainID: chainId.rawValue)
    }

    // MARK: - Browser Extension Code conversion

    public func address(browserExtensionCode: String) -> String? {
        do {
            let code = try extensionCode(from: browserExtensionCode)
            let message = try hash(data("GNO" + code.expirationDate))
            let result = try string(address: address(publicKey(signature(from: code), message)))
            return result
        } catch Error.invalidCodeJSON {
            ApplicationServiceRegistry.logger.error("Failed to convert extension code (\(browserExtensionCode))")
            return nil
        } catch {
            ApplicationServiceRegistry.logger.error(
                "Failed to extract public key from extension code (\(browserExtensionCode))")
            return nil
        }
    }

    private func extensionCode(from code: String) throws -> ExtensionCode {
        guard let data = code.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data),
            let extensionCode = ExtensionCode(json: json) else {
                throw Error.invalidCodeJSON
        }
        return extensionCode
    }

    private func signature(from code: ExtensionCode) -> EthSignature {
        return signature(from: (code.r, code.s, code.v))
    }

    private func signature(from value: (r: BInt, s: BInt, v: BInt)) -> EthSignature {
        return EthSignature(r: value.r.asString(withBase: 10), s: value.s.asString(withBase: 10), v: Int(value.v))
    }

    private func bintSignature(from signature: EthSignature) -> (r: BInt, s: BInt, v: BInt) {
        return (BInt.init(signature.r, radix: 10)!,
                BInt.init(signature.s, radix: 10)!,
                BInt.init(signature.v))
    }

    private func data(_ value: String) throws -> Data {
        guard let result = value.data(using: .utf8) else {
            throw Error.invalidString
        }
        return result
    }

    // MARK: - Contract Address computation

    public func contractAddress(from signature: EthSignature, for transaction: EthTransaction) throws -> String? {
        let sender = try address(publicKey(signature, hash(transaction)))
        let result = try string(address: hash(rlp(sender, transaction.nonce)).suffix(from: 12)) // last 20 of 32 bytes
        return result
    }

    private func rlp(_ values: Any...) throws -> Data {
        return try rlp(varArgs: values)
    }

    private func rlp(varArgs: [Any]) throws -> Data {
        return try RLP.encode(varArgs)
    }

    private func hash(_ value: Data) -> Data {
        return Crypto.hashSHA3_256(value)
    }

    private func hash(_ tx: EthTransaction) throws -> Data {
        return try hash(EthRawTransaction(to: "", tx.value, tx.data, tx.gas, tx.gasPrice, tx.nonce))
    }

    private func hash(_ tx: EthRawTransaction, _ signature: EthSignature? = nil) throws -> Data {
        return try hash(rlp(tx, signature: signature))
    }

    private func rlp(_ tx: EthRawTransaction, signature: EthSignature? = nil) throws -> Data {
        var toEncode: [Any] = [tx.nonce,
                               BInt(tx.gasPrice, radix: 10)!,
                               BInt(tx.gas, radix: 10)!,
                               Data(hex: tx.to),
                               tx.value,
                               Data(hex: tx.data)]
        if let signature = signature {
            let (r, s, v) = bintSignature(from: signature)
            toEncode.append(contentsOf: [v, r, s])
        }
        return try rlp(varArgs: toEncode)
    }

    private func data(from signature: EthSignature) throws -> Data {
        guard let r = BInt.init(signature.r, radix: 10), let s = BInt.init(signature.s, radix: 10) else {
            throw Error.invalidSignature
        }
        let v = BInt.init(signature.v)
        let data = signer.calculateSignature(r: r, s: s, v: v)
        return data
    }

    private func publicKey(_ signature: EthSignature, _ hash: Data) throws -> Data {
        guard let key = Crypto.publicKey(signature: try data(from: signature), of: hash, compressed: false) else {
            throw Error.invalidSignature
        }
        return key
    }

    private func address(_ publicKey: Data) -> Data {
        let string = ethereumService.createAddress(publicKey: publicKey)
        return Data(hex: string)
    }

    private func string(address: Data) -> String {
        return EthereumKit.Address(data: address).string
    }

    // MARK: - EOA address computation

    public func address(privateKey: MultisigWalletDomainModel.PrivateKey) -> MultisigWalletDomainModel.Address {
        let publicKey = ethereumService.createPublicKey(privateKey: privateKey.data)
        let address = ethereumService.createAddress(publicKey: publicKey)
        return Address(value: address)
    }

    // MARK: - EOA generation

    public func generateExternallyOwnedAccount() throws -> ExternallyOwnedAccount {
        let (mnemonicWords, privateKeyData, publicKeyData, address) =
            try ethereumService.createExternallyOwnedAccount(chainId: chainId)
        let account = ExternallyOwnedAccount(address: Address(value: address),
                                             mnemonic: Mnemonic(words: mnemonicWords),
                                             privateKey: PrivateKey(data: privateKeyData),
                                             publicKey: PublicKey(data: publicKeyData))
        return account
    }

    // MARK: - random numbers

    open func ecdsaRandomS() -> String {
        return String(BigUInt.randomInteger(lessThan: ECDSASignatureBounds.sRange.upperBound))
    }

    // MARK: - Signing messages

    public func sign(message: String, privateKey: MultisigWalletDomainModel.PrivateKey) throws -> EthSignature {
        let signature = try rawSignature(of: hash(data(message)), with: privateKey.data)
        return calculateRSV(from: signature)
    }

    private func calculateRSV(from rawSignature: Data) -> EthSignature {
        var result = signature(from: signer.calculateRSV(signiture: rawSignature))
        // FIXME: contribute to EthereumKit
        if chainId == .any && result.v > 28 {
            result.v += -35 + 27
        }
        return result
    }

    public func sign(transaction: EthRawTransaction,
                     privateKey: MultisigWalletDomainModel.PrivateKey) throws -> String {
        let rlpAppendix: EthSignature? = chainId == .any ? nil : EthSignature(r: "0", s: "0", v: chainId.rawValue)
        let signature = try calculateRSV(from: rawSignature(of: hash(transaction, rlpAppendix), with: privateKey.data))
        return try rlp(transaction, signature: signature).toHexString().addHexPrefix()
    }

    private func rawSignature(of data: Data, with privateKey: Data) throws -> Data {
        return try Crypto.sign(data, privateKey: privateKey)
    }

}

extension Int {

    enum Error: Swift.Error {
        case invalidIntValue(String)
    }

    init(string: String) throws {
        guard let v = Int(string) else { throw Error.invalidIntValue(string) }
        self = v
    }

}
