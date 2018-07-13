//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import UserNotifications

public extension UIApplication {

    func requestRemoteNotificationsRegistration() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
        UIApplication.shared.registerForRemoteNotifications()
    }

}
