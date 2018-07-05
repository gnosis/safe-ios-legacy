//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit
import IdentityAccessApplication

public class ErrorHandler {

    public struct Strings {
        public static let fatalErrorTitle = LocalizedString("onboarding.fatal.title",
                                                            comment: "Fatal error alert's title")
        public static let errorTitle = LocalizedString("onboarding.error.title",
                                                       comment: "Error alert's title")
        public static let ok = LocalizedString("onboarding.fatal.ok", comment: "Fatal error alert's Ok button title")
        public static let fatalErrorMessage = LocalizedString("onboarding.fatal.message",
                                                              comment: "Fatal error alert's message")
        public static let errorMessage = LocalizedString("generic.error.message",
                                                         comment: "Generic error message alert")
    }
    private static let instance = ErrorHandler()

    private init() {}

    public static func showFatalError(message: String = Strings.fatalErrorMessage,
                                      log: String,
                                      error: Error?,
                                      file: StaticString = #file,
                                      line: UInt = #line) {
        ApplicationServiceRegistry.logger.fatal(log, error: error, file: file, line: line)
        instance.showError(title: Strings.fatalErrorTitle, message: message, log: log, error: error) {
            fatalError(message + "; " + log)
        }
    }

    public static func showError(message: String = Strings.errorMessage,
                                 log: String,
                                 error: Error?,
                                 file: StaticString = #file,
                                 line: UInt = #line) {
        ApplicationServiceRegistry.logger.error(log, error: error, file: file, line: line)
        // swiftlint:disable trailing_closure
        instance.showError(title: Strings.errorTitle, message: message, log: log, error: error, action: {})
    }

    private func showError(title: String, message: String, log: String, error: Error?, action: @escaping () -> Void) {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        window.rootViewController = vc
        window.windowLevel = UIWindowLevelAlert + 1
        window.makeKeyAndVisible()
        let controller = alertController(title: title, message: message, log: log, action: action)
        vc.show(controller, sender: vc)
    }

    private func alertController(
        title: String, message: String, log: String, action: @escaping () -> Void) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Strings.ok, style: .destructive) { _ in action() })
        return alert
    }

    func terminate(message: String) {
        fatalError(message)
    }

}
