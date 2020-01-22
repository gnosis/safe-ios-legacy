//
//  Copyright © 2020 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import Common

public class HTTPTransactionHistoryService: TransactionHistoryDomainService {

    private let logger: Logger
    private let httpClient: JSONHTTPClient

    public init(url: URL, logger: Logger) {
        self.logger = logger
        httpClient = JSONHTTPClient(url: url, logger: logger)
    }

    public func safes(by owner: Address) throws -> [String] {
        let response = try httpClient.execute(request: GetSafesByOwnerRequest(owner: owner.value))
        return response.safes
    }

}

extension GetSafesByOwnerRequest: JSONRequest {

    public var httpMethod: String { return "GET" }
    public var urlPath: String { return "/owners/\(owner)/" }

    public typealias ResponseType = Response

}
