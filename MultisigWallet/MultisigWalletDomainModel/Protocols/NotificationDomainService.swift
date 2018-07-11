//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public enum NotificationDomainServiceError: String, LocalizedError, Hashable {
    case validationFailed
}

public protocol NotificationDomainService {

    func pair(pairingRequest: PairingRequest) throws
    func send(notificationRequest: SendNotificationRequest) throws

    func safeCreatedMessage(at address: String) -> String

}
