//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit
import Database

class UIKitFileSystemGuard: FileSystemGuard {

    override init() {
        super.init()
        subscribeForLockingEvents()
    }

    private func subscribeForLockingEvents() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didUnlock),
                                               name: UIApplication.protectedDataDidBecomeAvailableNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didLock),
                                               name: UIApplication.protectedDataWillBecomeUnavailableNotification,
                                               object: nil)
    }

}
