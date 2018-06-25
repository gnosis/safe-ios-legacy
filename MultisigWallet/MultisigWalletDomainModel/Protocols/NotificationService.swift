//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public struct BrowserExtensionData {
    let expirationDate: Date
    let signature: Signature
}

public protocol NotificationService {

    func pair(browserExtensionData: BrowserExtensionData, signature: Signature) throws

}
