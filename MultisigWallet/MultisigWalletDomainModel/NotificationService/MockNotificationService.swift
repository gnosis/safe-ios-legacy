//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import MultisigWalletDomainModel
import Foundation
import CommonTestSupport
import Common

/// Mock implementation of NotificationDomainService for testing.
public final class MockNotificationService: NotificationDomainService {

    public var shouldThrow = false
    public var shouldThrowNetworkError = false
    public var shouldThrowValidationFailedError = false
    public var delay: TimeInterval
    public var sentMessages: [String] = []

    public init(delay: TimeInterval = 0) {
        self.delay = delay
    }

    public var didPair = false
    public func pair(pairingRequest: PairingRequest) throws {
        Timer.wait(delay)
        try throwIfNeeded()
        didPair = true
    }

    public var didAuth = false
    public func auth(request: AuthRequest) throws {
        Timer.wait(delay)
        try throwIfNeeded()
        didAuth = true
    }

    public func authV2(request: AuthRequestV2) throws {
        // no-op
    }

    private func throwIfNeeded() throws {
        if shouldThrowNetworkError {
            throw JSONHTTPClient.Error.networkRequestFailed(URLRequest(url: URL(string: "http://test.url")!), nil, nil)
        }
        if shouldThrowValidationFailedError {
            throw NotificationDomainServiceError.validationFailed
        }
        if shouldThrow { throw TestError.error }
    }

    public func send(notificationRequest: SendNotificationRequest) throws {
        sentMessages.append("to:\(notificationRequest.devices.first!) msg:\(notificationRequest.message)")
    }

    public func safeCreatedMessage(at address: String) -> String {
        return "SafeCreatedMessage_\(address)"
    }

    public func requestConfirmationMessage(for transaction: Transaction, hash: Data) -> String {
        return "RequestConfirmationMessage_\(transaction)_\(hash.toHexString().addHexPrefix())"
    }

    public func transactionSentMessage(for transaction: Transaction) -> String {
        return "TransactionSentMessage_\(transaction)"
    }

    public func deletePair(request: DeletePairRequest) throws {
        // empty
    }

}
