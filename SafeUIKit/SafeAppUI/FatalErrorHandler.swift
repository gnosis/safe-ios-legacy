//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit
import IdentityAccessApplication

public class FatalErrorHandler {

    public struct Strings {
        public static let title = LocalizedString("onboarding.fatal.title", comment: "Fatal error alert's title")
        public static let ok = LocalizedString("onboarding.fatal.ok", comment: "Fatal error alert's Ok button title")
        public static let message = LocalizedString("onboarding.fatal.message", comment: "Fatal error alert's message")
    }
    private static let instance = FatalErrorHandler()

    private init() {}

    public static func showFatalError(message: String = Strings.message, log: String, error: Error?) {
        instance.showFatalError(message: message, log: log, error: error)
    }

    private func showFatalError(message: String, log: String, error: Error?) {
        ApplicationServiceRegistry.logger.fatal(log, error: error)
        let window = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        window.rootViewController = vc
        window.windowLevel = UIWindowLevelAlert + 1
        window.makeKeyAndVisible()
        vc.show(alertController(message: message, log: log), sender: vc)
    }

    private func alertController(message: String, log: String) -> UIAlertController {
        let alert = UIAlertController(title: Strings.title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Strings.ok, style: .destructive) { [weak self] _ in
            self?.terminate(message: log)
        })
        return alert
    }

    func terminate(message: String) {
        fatalError(message)
    }

}
