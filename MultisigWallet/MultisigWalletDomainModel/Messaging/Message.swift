//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public class Message {

    public let type: String

    public init(type: String) {
        self.type = type
    }

}

extension Message: Equatable {

    public static func ==(lhs: Message, rhs: Message) -> Bool {
        return lhs.type == rhs.type
    }

}
