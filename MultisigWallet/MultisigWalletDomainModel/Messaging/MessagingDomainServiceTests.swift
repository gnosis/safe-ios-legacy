//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import MultisigWalletImplementations

class MessagingDomainServiceTests: XCTestCase {

    let notificationService = MockNotificationService()
    let eoaRepository = InMemoryExternallyOwnedAccountRepository()
    let encryptionService = MockEncryptionService()
    let messagingService = MessagingDomainService()
    let senderAccount = ExternallyOwnedAccount(address: Address.deviceAddress,
                                               mnemonic: Mnemonic(words: ["one", "two"]),
                                               privateKey: PrivateKey(data: Data()),
                                               publicKey: PublicKey(data: Data()))

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: notificationService, for: NotificationDomainService.self)
        DomainRegistry.put(service: eoaRepository, for: ExternallyOwnedAccountRepository.self)
        DomainRegistry.put(service: encryptionService, for: EncryptionDomainService.self)
        eoaRepository.save(senderAccount)
    }

    func test_whenSendingMessage_thenSendsThroughNotificaitonService() throws {
        let message = OutgoingMessage(type: "myMessage", to: Address.extensionAddress, from: senderAccount.address)
        try messagingService.send(message)
        XCTAssertEqual(notificationService.sentMessages, ["to:\(message.recipient.value) msg:\(message.stringValue)"])
    }

    func test_whenReceivingMessage_thenNotifiesHandlers() {
        let handler = Handler()
        messagingService.subscribe(handler)
        let message = Message.test
        messagingService.receive(message)
        XCTAssertEqual(handler.handledMessages, [message])
    }

    func test_whenUnsubscirbed_thenNoLongerReceivesMessages() {
        let handler = Handler()
        messagingService.subscribe(handler)
        messagingService.unsubscribe(handler)
        messagingService.receive(.test)
        XCTAssertTrue(handler.handledMessages.isEmpty)
    }

    func test_whenHandlerCanNotHandle_thenMessageIsNotDelivered() {
        let handler = Handler()
        handler.isEnabled = false
        messagingService.subscribe(handler)
        messagingService.receive(.test)
        XCTAssertTrue(handler.handledMessages.isEmpty)
    }

}

fileprivate extension Message {

    static let test = Message(type: "MyMessage")

}

extension MessagingDomainServiceTests {

    class Handler: MessageHandler {

        var isEnabled = true
        var handledMessages = [Message]()

        func canHandle(_ message: Message) -> Bool {
            return isEnabled
        }

        func handle(_ message: Message) {
            handledMessages.append(message)
        }
    }

}
