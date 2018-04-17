//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol GatekeeperRepository {

    func save(_ keeper: Gatekeeper) throws
    func gatekeeper() -> Gatekeeper?
    func nextId() -> GatekeeperID

}
