//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class MockTransactionRelayService1: TransactionRelayDomainService {

    private var expected_createSafeCreationTransaction:
        [(request: SafeCreationRequest, response: SafeCreationRequest.Response)] = []
    private var actual_createSafeCreationTransaction: [SafeCreationRequest] = []
    private var createSafeCreationTransaction_throws_error: Error?

    func expect_createSafeCreationTransaction(_ request: SafeCreationRequest,
                                              _ response: SafeCreationRequest.Response) {
        expected_createSafeCreationTransaction.append((request, response))
    }

    func expect_createSafeCreationTransaction_throw(_ error: Error) {
        createSafeCreationTransaction_throws_error = error
    }

    func createSafeCreationTransaction(request: SafeCreationRequest) throws -> SafeCreationRequest.Response {
            actual_createSafeCreationTransaction.append(request)
            if let error = createSafeCreationTransaction_throws_error {
                throw error
            }
            return expected_createSafeCreationTransaction[actual_createSafeCreationTransaction.count - 1].response
    }

    func estimateSafeCreation(request: EstimateSafeCreationRequest) throws
        -> [EstimateSafeCreationRequest.Estimation] {
        preconditionFailure("not implemented")
    }

    func verify(line: UInt = #line, file: StaticString = #file) {
        XCTAssertEqual(actual_createSafeCreationTransaction.map { $0.toString() },
                       expected_createSafeCreationTransaction.map { $0.request.toString() },
                       file: file,
                       line: line)
        XCTAssertEqual(actual_startSafeCreation.map { $0.value },
                       expected_startSafeCreation.map { $0.value },
                       file: file,
                       line: line)
        XCTAssertEqual(actual_safeCreationTransactionHash.map { $0.value },
                       expected_safeCreationTransactionHash.map { $0.address.value },
                       file: file,
                       line: line)
    }

    private var expected_startSafeCreation = [Address]()
    private var actual_startSafeCreation = [Address]()
    private var startSafeCreation_throws_error: Error?

    func expect_startSafeCreation_throw(_ error: Error) {
        startSafeCreation_throws_error = error
    }

    func expect_startSafeCreation(address: Address) {
        expected_startSafeCreation.append(address)
    }

    func startSafeCreation(address: Address) throws {
        actual_startSafeCreation.append(address)
        if let error = startSafeCreation_throws_error {
            throw error
        }
    }

    private var expected_safeCreationTransactionHash = [(address: Address, hash: TransactionHash?)]()
    private var actual_safeCreationTransactionHash = [Address]()
    private var safeCreationTransactionHash_throws_error: Error?

    func expect_safeCreationTransactionHash_throw(_ error: Error?) {
        safeCreationTransactionHash_throws_error = error
    }

    func expect_safeCreationTransactionHash(address: Address, hash: TransactionHash?) {
        expected_safeCreationTransactionHash.append((address, hash))
    }

    func safeCreationTransactionHash(address: Address) throws -> TransactionHash? {
        actual_safeCreationTransactionHash.append(address)
        if let error = safeCreationTransactionHash_throws_error {
            throw error
        }
        return expected_safeCreationTransactionHash[actual_safeCreationTransactionHash.count - 1].hash
    }

    func gasPrice() throws -> SafeGasPriceResponse {
        preconditionFailure("not implemented")
    }

    func submitTransaction(request: SubmitTransactionRequest) throws -> SubmitTransactionRequest.Response {
        preconditionFailure("not implemented")
    }

    func estimateTransaction(request: EstimateTransactionRequest) throws -> EstimateTransactionRequest.Response {
        preconditionFailure("not implemented")
    }

    func multiTokenEstimateTransaction(request: MultiTokenEstimateTransactionRequest) throws ->
        MultiTokenEstimateTransactionRequest.Response {
            return .init(lastUsedNonce: nil, estimations: [])
    }

}
