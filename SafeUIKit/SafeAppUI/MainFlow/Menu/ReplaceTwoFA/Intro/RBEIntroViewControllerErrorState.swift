//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

extension RBEIntroViewController {

    class ErrorState: BaseErrorState {

        enum Strings {
            static let errorTitle = LocalizedString("error", comment: "Error")
            static let errorOK = LocalizedString("ok", comment: "OK")
        }

        override func didEnter(controller: RBEIntroViewController) {
            controller.present(makeAlert(), animated: true, completion: nil)
            controller.stopIndicateLoading()
            controller.showStart()
            controller.enableStart()
        }

        private func makeAlert() -> UIViewController {
            let alert = UIAlertController(title: Strings.errorTitle,
                                          message: error.localizedDescription,
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: Strings.errorOK, style: .default, handler: nil)
            alert.addAction(okAction)
            return alert
        }

        override func retry(controller: RBEIntroViewController) {
            // nothing
        }

        override func start(controller: RBEIntroViewController) {
            controller.transition(to: StartingState())
        }

    }

}
