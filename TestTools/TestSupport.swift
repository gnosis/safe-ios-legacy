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
            default: break
            }
        }
    }

}
