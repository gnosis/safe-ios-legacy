//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import IdentityAccessApplication
import MultisigWalletImplementations
import MultisigWalletDomainModel
import MultisigWalletApplication
import SafeAppUI
import BigInt

protocol Resettable: class {
    func resetAll()
}

final class StubEncryptionService: EncryptionService {

    override func randomSaltNonce() -> BigUInt {
        return BigUInt("1809251394333065553493296640760748560207343510400633813116524750123642650623")
    }

}

final class TestSupport {

    static let shared = TestSupport()
    private var resettableObjects = [Resettable]()
    private var authenticationService: AuthenticationApplicationService {
        return ApplicationServiceRegistry.authenticationService
    }

    func addResettable(_ object: Resettable) {
        resettableObjects.append(object)
    }
    
    func setUp(_ arguments: [String] = ProcessInfo.processInfo.arguments) {
        do {
            var iterator = arguments.makeIterator()
            while let argument = iterator.next() {
                switch argument {
                case ApplicationArguments.resetAllContentAndSettings:
                    resettableObjects.forEach { $0.resetAll() }
                case ApplicationArguments.setPassword:
                    if let password = iterator.next() {
                        try authenticationService.registerUser(password: password)
                    }
                case ApplicationArguments.setSessionDuration:
                    if let duration = timeInterval(&iterator) {
                        try authenticationService.configureSession(duration)
                    }
                case ApplicationArguments.setMaxPasswordAttempts:
                    if let attemptCountStr = iterator.next(),
                        let attemptCount = Int(attemptCountStr) {
                        try authenticationService.configureMaxPasswordAttempts(attemptCount)
                    }
                case ApplicationArguments.setAccountBlockedPeriodDuration:
                    if let blockingTime = timeInterval(&iterator) {
                        try authenticationService.configureBlockDuration(blockingTime)
                    }
                case ApplicationArguments.setMockServerResponseDelay:
                    if let delayTime = timeInterval(&iterator) {
                        let mockService = MockTransactionRelayService(averageDelay: delayTime, maxDeviation: 0)
                        DomainRegistry.put(service: mockService, for: TransactionRelayDomainService.self)
                        DomainRegistry.put(service: DemoEthereumNodeService(delay: delayTime),
                                           for: EthereumNodeDomainService.self)
                        DomainRegistry.put(service: MockNotificationService(delay: delayTime),
                                           for: NotificationDomainService.self)
                        DomainRegistry.put(service: StubEncryptionService(), for: EncryptionDomainService.self)
                    }
                case ApplicationArguments.setMockTransactionsRelayService:
                    var transactionRelayService = MockTransactionRelayService(averageDelay: 0, maxDeviation: 0)
                    if let parameters = iterator.next()?.split(separator: ",") {
                        let delayParameters = parameters.filter { $0.range(of: "delay=") != nil }
                        if !delayParameters.isEmpty {
                            let delayParam = delayParameters.first!
                            let delay = TimeInterval(delayParam.suffix(from: delayParam.firstIndex(of: "=")!).dropFirst())!
                            transactionRelayService = MockTransactionRelayService(averageDelay: delay, maxDeviation: 0)
                        }
                        if parameters.contains("networkError") {
                            transactionRelayService.shouldThrowNetworkError = true
                        } else if parameters.contains("genericError") {
                            transactionRelayService.shouldThrow = true
                        }
                    }
                    DomainRegistry.put(service: transactionRelayService, for: TransactionRelayDomainService.self)
                case ApplicationArguments.setMockNotificationService:
                    let notificationService = MockNotificationService()
                    var delay: TimeInterval = 0
                    if let parameters = iterator.next()?.split(separator: ",") {
                        let delayParameters = parameters.filter { $0.range(of: "delay=") != nil }
                        if !delayParameters.isEmpty {
                            let delayParam = delayParameters.first!
                            delay = TimeInterval(delayParam.suffix(from: delayParam.firstIndex(of: "=")!).dropFirst())!
                            notificationService.delay = delay
                        }
                        if parameters.contains("networkError") {
                            notificationService.shouldThrowNetworkError = true
                        } else if parameters.contains("validationError") {
                            notificationService.shouldThrowValidationFailedError = true
                            ErrorHandler.instance.crashOnFatalError = false
                        } else if parameters.contains("genericError") {
                            notificationService.shouldThrow = true
                        }
                    }
                    DomainRegistry.put(service: notificationService, for: NotificationDomainService.self)
                case ApplicationArguments.setTestSafe:
                    let walletService = MockWalletApplicationService()
                    walletService.estimatedFee_output = 0
                    walletService.createReadyToUseWallet()
                    ApplicationServiceRegistry.put(service: walletService, for: WalletApplicationService.self)
                default: break
                }
            }
        } catch let e {
            preconditionFailure("Failed to set up test support: \(e)")
        }
    }

    private func timeInterval(_ iterator: inout IndexingIterator<[String]>) -> TimeInterval? {
        if let string = iterator.next(),
            let time = TimeInterval(string) {
            return time
        }
        return nil
    }

}
