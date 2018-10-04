//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Represents message sent from the mobile device owner to a browser extension owner.
public class OutgoingMessage: Message {

    /// Recipient of the message
    public let recipient: Address
    /// Sender of the message
    public let sender: Address

    /// Serialized message as String (JSON). Should be overriden by subclasses.
    public var stringValue: String {
        return type
    }

    /// Creates new OutgoingMessage
    ///
    /// - Parameters:
    ///   - type: type of the message
    ///   - to: recipient's address
    ///   - from: sender's address
    public init(type: String, to: Address, from: Address) {
        self.recipient = to
        self.sender = from
        super.init(type: type)
    }

    /// Utility method to convert Encodable to String. Intended to be used in implementation of `stringValue`
    ///
    /// - Parameter json: object to convert
    /// - Returns: serialized json object
    internal func jsonString<T: Encodable>(from json: T) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try! encoder.encode(json)
        return String(data: data, encoding: .utf8)!
    }

}

extension OutgoingMessage {

    static func ==(lhs: OutgoingMessage, rhs: OutgoingMessage) -> Bool {
        return lhs.type == rhs.type &&
            lhs.recipient == rhs.recipient &&
            lhs.sender == rhs.sender
    }

}
