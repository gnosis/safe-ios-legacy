//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class MockNotificationService1: NotificationDomainService {

    func pair(pairingRequest: PairingRequest) throws {
        preconditionFailure()
    }

    func auth(request: AuthRequest) throws {
        preconditionFailure()
    }

    private var expected_send = [SendNotificationRequest]()
    private var actual_send = [SendNotificationRequest]()
    private var send_throws_error: Error?

    func expect_send(notificationRequest: SendNotificationRequest) {
        expected_send.append(notificationRequest)
    }

    func expect_send_throw(_ error: Error) {
        send_throws_error = error
    }

    func send(notificationRequest: SendNotificationRequest) throws {
        actual_send.append(notificationRequest)
        if let error = send_throws_error {
            throw error
        }
    }

    private var expected_safeCreatedMessage = [(address: String, message: String)]()
    private var actual_safeCreatedMessage = [String]()

    func expect_safeCreatedMessage(at address: String, message: String) {
        expected_safeCreatedMessage.append((address, message))
    }

    func safeCreatedMessage(at address: String) -> String {
        actual_safeCreatedMessage.append(address)
        return expected_safeCreatedMessage[actual_safeCreatedMessage.count - 1].message
    }

    func verify(line: UInt = #line, file: StaticString = #file) {
        XCTAssertEqual(actual_send.map { $0.toString() },
                       expected_send.map { $0.toString() },
                       file: file,
                       line: line)
        XCTAssertEqual(actual_safeCreatedMessage,
                       expected_safeCreatedMessage.map { $0.address },
                       file: file,
                       line: line)
    }

    func requestConfirmationMessage(for transaction: Transaction, hash: Data) -> String {
        preconditionFailure()
    }

    func transactionSentMessage(for transaction: Transaction) -> String {
        preconditionFailure()
    }

    func deletePair(request: DeletePairRequest) throws {
        preconditionFailure()
    }

}
