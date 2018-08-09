//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Represents wallet owner.
public struct Owner: Hashable, Codable {
    public internal(set) var address: Address
}
