//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol MessageHandler: class {

    func canHandle(_ message: Message) -> Bool
    func handle(_ message: Message)

}
