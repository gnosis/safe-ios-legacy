//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol SingleGatekeeperRepository {

    func save(_ gatekeeper: Gatekeeper) throws
    func remove(_ gatekeeper: Gatekeeper) throws
    func gatekeeper() -> Gatekeeper?
    func nextId() -> GatekeeperID

}
