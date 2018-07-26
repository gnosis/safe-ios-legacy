//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public class Message {

    public let type: String

    public var stringValue: String {
        return type
    }

    public init(type: String) {
        self.type = type
    }

}

extension Message: Equatable {

    public static func ==(lhs: Message, rhs: Message) -> Bool {
        return lhs.type == rhs.type
    }

}

public class OutgoingMessage: Message {

    public let recipient: Address
    public let sender: Address

    public init(type: String, to: Address, from: Address) {
        self.recipient = to
        self.sender = from
        super.init(type: type)
    }

}

extension OutgoingMessage {

    static func ==(lhs: OutgoingMessage, rhs: OutgoingMessage) -> Bool {
        return lhs.type == rhs.type &&
            lhs.recipient == rhs.recipient &&
            lhs.sender == rhs.sender
    }

}
