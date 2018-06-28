//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumDomainModel
import EthereumApplication

public class GnosisTransactionRelayService: TransactionRelayDomainService {

    enum Error: Swift.Error {
        case networkRequestFailed(URLRequest, URLResponse?)
    }

    private typealias URLDataTaskResult = (data: Data?, response: URLResponse?, error: Swift.Error?)

    public init () {}

    public func createSafeCreationTransaction(owners: [Address],
                                              confirmationCount: Int,
                                              randomUInt256: String) throws -> SignedSafeCreationTransaction {
        let jsonRequest = SafeCreationTransactionRequest(owners: owners,
                                                         confirmationCount: confirmationCount,
                                                         randomUInt256: randomUInt256)
        let response = try execute(request: jsonRequest)
        return SignedSafeCreationTransaction(safe: Address(value: response.safe),
                                             payment: Ether(amount: Int(response.payment)!),
                                             signature: Signature(r: response.signature.r,
                                                                  s: response.signature.s,
                                                                  v: Int(response.signature.v)!),
                                             tx: Transaction())
    }

    public func startSafeCreation(address: Address) throws -> TransactionHash {
        return TransactionHash(value: "")
    }

    private func execute<T: JSONRequest>(request: T) throws -> T.ResponseType {
        let urlRequest = try self.urlRequest(from: request)
        let result = send(urlRequest)
        let response: T.ResponseType = try self.response(from: urlRequest, result: result)
        return response
    }

    private func send(_ request: URLRequest) -> URLDataTaskResult {
        var result: URLDataTaskResult
        let semaphore = DispatchSemaphore(value: 0)
        ApplicationServiceRegistry.logger.debug("Sending request \(request)")

        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            result = (data, response, error)
            semaphore.signal()
        }
        dataTask.resume()
        semaphore.wait()
        ApplicationServiceRegistry.logger.debug("Received response \(result)")
        return result
    }

    private func urlRequest<T: JSONRequest>(from jsonRequest: T) throws -> URLRequest {
        let serviceURL = Keys.transactionRelayServiceURL
        let url = serviceURL.appendingPathComponent(jsonRequest.urlPath)
        var request = URLRequest(url: url)
        request.httpMethod = jsonRequest.httpMethod
        request.httpBody = try JSONEncoder().encode(jsonRequest)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    private func response<T: Decodable>(from request: URLRequest, result: URLDataTaskResult) throws -> T {
        if let error = result.error {
            throw error
        }
        guard let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode / 100 == 2,
            let data = result.data else {
                throw Error.networkRequestFailed(request, result.response)
        }
        if let rawResponse = String(data: data, encoding: .utf8) {
            ApplicationServiceRegistry.logger.debug(rawResponse)
        }
        let response: T
        do {
            response = try JSONDecoder().decode(T.self, from: data)
        } catch let error {
            print(error)
            throw error
        }
        return response
    }

}

protocol JSONRequest: Encodable {

    var httpMethod: String { get }
    var urlPath: String { get }

    associatedtype ResponseType: Decodable

}


struct SafeCreationTransactionRequest: JSONRequest {

    let httpMethod = "POST"
    let urlPath = "safes/"
    typealias ResponseType = SafeCreationTransactionRequest.Response

    let owners: [String]
    let threshold: String
    let s: String

    enum CodingKeys: CodingKey {
        case owners
        case threshold
        case s
    }

    init(owners: [Address], confirmationCount: Int, randomUInt256: String) {
        self.owners = owners.map { $0.value }
        threshold = String(confirmationCount)
        s = randomUInt256
    }

    struct Response: Decodable {
        let signature: Response.Signature
        let tx: Response.Transaction
        let safe: String
        let payment: String

        struct Signature: Decodable {
            let r: String
            let s: String
            let v: String
        }

        struct Transaction: Decodable {
            let from: String
            let value: Int
            let data: String
            let gas: String
            let gasPrice: String
            let nonce: Int
        }
    }

}
