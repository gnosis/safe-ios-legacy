//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

/// Base class for incoming responses to transaction confirmation request.
public class TransactionDecisionMessage: Message {

    /// ERC191 hash of thransaction
    public let hash: Data
    /// Signature of transaction by the sender
    public let signature: EthSignature

    /// Type of the message, overriden by subclasses.
    internal class var messageType: String {
        return ""
    }

    /// Creates new message with transaction hash and signature
    ///
    /// - Parameters:
    ///   - hash: hash of the transaction
    ///   - signature: signature of the transaction
    public init(hash: Data, signature: EthSignature) {
        self.hash = hash
        self.signature = signature
        super.init(type: Swift.type(of: self).messageType)
    }

    /// Creates new message from a json object structure (usually received from push notification).
    ///
    /// - Parameter userInfo: dictionary of message values
    public convenience init?(userInfo: [AnyHashable: Any]) {
        guard let json = try? OBJCJSONDecoder().decode(JSON.self, from: userInfo),
            json.type == Swift.type(of: self).messageType,
            let hash = Optional(Data(ethHex: json.hash)),
            !hash.isEmpty,
            let v = Int(json.v),
            ECDSASignatureBounds.isWithinBounds(r: json.r, s: json.s, v: v)
            else { return nil }
        self.init(hash: hash, signature: EthSignature(r: json.r, s: json.s, v: v))
    }

    private struct JSON: Decodable {
        var type: String
        var hash: String
        var r: String
        var s: String
        var v: String
    }

}

/// Indicates that transaction was confirmed by another wallet owner.
/// Hash of transaction is calculated according to ERC191
public class TransactionConfirmedMessage: TransactionDecisionMessage {

    override class var messageType: String {
        return "confirmTransaction"
    }

}

/// Indicates that transaction was rejected by another wallet owner.
/// For the rejection message, transaction hash calculated as sha3('GNO' + tx hash + 'rejectTransaction')
public class TransactionRejectedMessage: TransactionDecisionMessage {

    override class var messageType: String {
        return "rejectTransaction"
    }

}
