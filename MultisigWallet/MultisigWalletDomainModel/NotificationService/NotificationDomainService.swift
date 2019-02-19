//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Error thrown from NotificationDomainService methods
///
/// - validationFailed: pairing request validation failed
public enum NotificationDomainServiceError: String, LocalizedError, Hashable {
    case validationFailed
}

public protocol NotificationDomainService {

    /// Attempt to create device pair for further communication
    ///
    /// - Parameter pairingRequest: request to pair with another device
    /// - Throws: error in case of network error or validation error
    func pair(pairingRequest: PairingRequest) throws

    /// Deletes a device pair, the devices will be no longer authorized to send notifications to each other
    ///
    /// - Parameter request: request with signature and other device address
    /// - Throws: error in case of network error or server error
    func deletePair(request: DeletePairRequest) throws

    /// Authenticate this device with AuthRequest to be able to receive notifications.
    ///
    /// - Parameter request: auth request to allow receiving notifications.
    /// - Throws: network error or validation error
    func auth(request: AuthRequest) throws

    /// Sends message notification to another device.
    /// Pairing should exist for the recipient to receive the notification.
    ///
    /// - Parameter notificationRequest: notification to send to a recipient
    /// - Throws: network error
    func send(notificationRequest: SendNotificationRequest) throws

    // MARK: - Message factory methods

    /// Notifies recipient of created wallet at address
    ///
    /// - Parameter address: address of created wallet
    /// - Returns: message as string
    func safeCreatedMessage(at address: String) -> String

    /// Notifies recipient of a new transaction to be confirmed.
    ///
    /// - Parameters:
    ///   - transaction: transaction data to confirm
    ///   - hash: hash of the transaction
    /// - Returns: message string
    func requestConfirmationMessage(for transaction: Transaction, hash: Data) -> String

    /// Notifies recipient that transaction was accepted by the blockchain
    ///
    /// - Parameter transaction: transaction data to notify about
    /// - Returns: message string
    func transactionSentMessage(for transaction: Transaction) -> String

}
