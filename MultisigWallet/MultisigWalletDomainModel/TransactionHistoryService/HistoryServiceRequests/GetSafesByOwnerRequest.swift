//
//  Copyright © 2020 Gnosis Ltd. All rights reserved.
//

import Foundation

struct GetSafesByOwnerRequest: Encodable {

    public let owner: String

    public init(owner: String) {
        self.owner = owner
    }

    public struct Response: Decodable {
        let safes: [String]

        public init(safes: [String]) {
            self.safes = safes
        }
    }

}
