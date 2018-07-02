//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import Common

final public class HTTPNotificationService: NotificationDomainService {

    private let httpClient = JSONHTTPClient(url: Keys.notificationServiceURL,
                                            logger: MockLogger())

    public func pair(pairingRequest: PairingRequest) throws {
        let response = try httpClient.execute(request: pairingRequest)
        let browserExtensionAddress = pairingRequest.temporaryAuthorization.extensionAddress!
        let deviceOwnerAddress = pairingRequest.deviceOwnerAddress!
        guard response.devicePair.contains(browserExtensionAddress) &&
            response.devicePair.contains(deviceOwnerAddress) else {
            throw NotificationDomainServiceError.validationFailed
        }
    }

    public init() {}

}

extension PairingRequest: JSONRequest {

    public var httpMethod: String { return "POST" }
    public var urlPath: String { return "/api/v1/pairing/" }

    public struct DevicePair: Decodable {

        let devicePair: [String]

    }

    public typealias ResponseType = DevicePair

}
