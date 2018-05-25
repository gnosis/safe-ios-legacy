//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol EncryptionService {

    func encrypted(_ plainText: String) -> String

}
