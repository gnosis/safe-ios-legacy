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
    private let account: AccountProtocol

    init(account: AccountProtocol = Account.shared) {
        self.account = account
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
                    try? account.setMasterPassword(password)
                }
            case ApplicationArguments.setSessionDuration:
                if let duration = timeInterval(&iterator) {
                    account.sessionDuration = duration
                }
            case ApplicationArguments.setMaxPasswordAttempts:
                if let attemptCountStr = iterator.next(),
                    let attemptCount = Int(attemptCountStr) {
                    account.maxPasswordAttempts = attemptCount
                }
            case ApplicationArguments.setAccountBlockedPeriodDuration:
                if let blockingTime = timeInterval(&iterator) {
                    account.blockedPeriodDuration = blockingTime
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
