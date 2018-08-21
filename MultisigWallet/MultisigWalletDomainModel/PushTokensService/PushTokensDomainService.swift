//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

/// Used to retrieve push notification token
public protocol PushTokensDomainService {

    /// Fetches push token, if it is available
    ///
    /// - Returns: push token or nil if it is unavailable.
    func pushToken() -> String?

}
