//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

protocol SessionRepository {

    func save(_ session: XSession) throws
    func activeSession() -> XSession?
    func nextId() -> SessionID

}
