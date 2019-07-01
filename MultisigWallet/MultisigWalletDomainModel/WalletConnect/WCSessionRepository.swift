//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol WCSessionRepository {

    func save(_ item: WCSession)
    func remove(id: WCSessionID)
    func find(id: WCSessionID) -> WCSession?
    func all(withClientMetaOnly: Bool) -> [WCSession]

}
