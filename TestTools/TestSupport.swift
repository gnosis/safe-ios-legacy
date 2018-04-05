//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

protocol Resettable: class {
    func resetAll()
}

final class TestSupport {

    static let shared = TestSupport()
    private var resettableObjects = [Resettable]()
    private let identityService: IdentityApplicationService

    init(account: AccountProtocol = Account.shared) {
        identityService = IdentityApplicationService(account: account)
    }

    func addResettable(_ object: Resettable) {
        resettableObjects.append(object)
    }

    func setUp(_ arguments: [String] = ProcessInfo.processInfo.arguments) {
        var iterator = arguments.makeIterator()
        while let argument = iterator.next() {
            switch argument {
            case ApplicationArguments.resetAllContentAndSettings:
                resettableObjects.forEach { $0.resetAll() }
            case ApplicationArguments.setPassword:
                if let password = iterator.next() {
                    try? identityService.registerUser(password: password)
                }
            case ApplicationArguments.setSessionDuration:
                if let duration = timeInterval(&iterator) {
                    identityService.configureSession(duration)
                }
            case ApplicationArguments.setMaxPasswordAttempts:
                if let attemptCountStr = iterator.next(),
                    let attemptCount = Int(attemptCountStr) {
                    identityService.configureMaxPasswordAttempts(attemptCount)
                }
            case ApplicationArguments.setAccountBlockedPeriodDuration:
                if let blockingTime = timeInterval(&iterator) {
                    identityService.configureBlockDuration(blockingTime)
                }
            default: break
            }
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
