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
        print(response)
    }

    public init() {}

}

extension PairingRequest: JSONRequest {

    public var httpMethod: String { return "POST" }
    public var urlPath: String { return "/api/v1/pairing/" }

    public struct EmptyResponse: Decodable {}

    public typealias ResponseType = EmptyResponse

}
