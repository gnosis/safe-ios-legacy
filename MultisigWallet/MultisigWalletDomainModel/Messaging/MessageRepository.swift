//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol MessageRepository {

    func save(_ message: Message)
    func remove(_ message: Message)

}
