//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public class OutgoingMessage: Message {

    public let recipient: Address
    public let sender: Address

    public var stringValue: String {
        return type
    }

    public init(type: String, to: Address, from: Address) {
        self.recipient = to
        self.sender = from
        super.init(type: type)
    }

    internal func jsonString<T: Encodable>(from json: T) -> String {
        let data = try! JSONEncoder().encode(json)
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
