//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol TokenListDomainService {

    /// Returns a list of token items to display to the user.
    ///
    /// - Returns: a list of token items
    /// - Throws: errors
    func items() throws -> [TokenListItem]

}
