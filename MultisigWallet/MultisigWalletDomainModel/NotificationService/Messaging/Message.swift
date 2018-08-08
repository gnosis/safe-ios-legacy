//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Represents notification message sent between wallet owners (mobile device wallet owner and browser extension owner)
public class Message {

    /// Message type identifies kind of the message.
    public let type: String

    /// Create new message of specified type
    ///
    /// - Parameter type: type of the message
    public init(type: String) {
        self.type = type
    }

}

extension Message: Equatable {

    public static func ==(lhs: Message, rhs: Message) -> Bool {
        return lhs.type == rhs.type
    }

}
