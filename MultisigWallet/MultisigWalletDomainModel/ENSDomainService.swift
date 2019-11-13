//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol ENSDomainService {

    func address(for name: String) throws -> Address
    func name(for address: Address) throws -> String?

}
