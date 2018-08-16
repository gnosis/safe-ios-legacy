//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol TokenListDomainService {

    /// Returns a list of ERC20 tokens to display to the user.
    ///
    /// - Returns: a list of ERC20 tokens
    /// - Throws: errors
    func tokens() throws -> [Token]

}
