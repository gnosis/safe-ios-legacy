//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public class MessagingDomainService {

    private var handlers = [MessageHandler]()

    public init() {}

    public func send(_ message: OutgoingMessage) throws {
        let notificationService = DomainRegistry.notificationService
        let eoaRepository = DomainRegistry.externallyOwnedAccountRepository
        let encryptionService = DomainRegistry.encryptionService
        let senderEOA = eoaRepository.find(by: message.sender)!
        let signature = encryptionService.sign(message: "GNO" + message.stringValue, privateKey: senderEOA.privateKey)
        let request = SendNotificationRequest(message: message.stringValue,
                                              to: message.recipient.value,
                                              from: signature)
        try notificationService.send(notificationRequest: request)
    }

    public func receive(_ message: Message) {
        handlers.filter { $0.canHandle(message) }.forEach { $0.handle(message) }
    }

    public func subscribe(_ handler: MessageHandler) {
        handlers.append(handler)
    }

    public func unsubscribe(_ handler: MessageHandler) {
        guard let index = handlers.index(where: { $0 === handler }) else { return }
        handlers.remove(at: index)
    }

}
