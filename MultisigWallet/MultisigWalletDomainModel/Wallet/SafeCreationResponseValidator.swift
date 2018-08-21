//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common
import BigInt

public enum SafeCreationValidationError: Error {
    case invalidSignature
    case invalidTransaction
}

public class SafeCreationResponseValidator: Assertable {

    public init () {}

    func validate(_ response: SafeCreationTransactionRequest.Response, request: SafeCreationTransactionRequest) throws {
        try assertEqual(response.signature.s, request.s, SafeCreationValidationError.invalidSignature)
        try assertNotNil(response.intPayment, SafeCreationValidationError.invalidTransaction)
        try assertTrue(response.signature.isValid, SafeCreationValidationError.invalidSignature)
        try assertEqual(response.recoveredContractAddress, response.safe, SafeCreationValidationError.invalidSignature)
    }

}

extension SafeCreationTransactionRequest.Response.Signature {

    var isValid: Bool {
        guard let v = Int(v) else { return false }
        return ECDSASignatureBounds.isWithinBounds(r: r, s: s, v: v)
    }

    var ethSignature: EthSignature {
        return EthSignature(r: r, s: s, v: Int(v)!)
    }

}

extension SafeCreationTransactionRequest.Response.Transaction {

    var ethTransaction: EthTransaction {
        return (from, value, data, gas, gasPrice, nonce)
    }

}

extension SafeCreationTransactionRequest.Response {

    var recoveredContractAddress: String? {
        return DomainRegistry.encryptionService.contractAddress(from: signature.ethSignature,
                                                                for: tx.ethTransaction)
    }

    var intPayment: BigInt? {
        return BigInt(payment)
    }

}
