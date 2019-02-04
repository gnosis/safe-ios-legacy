//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

extension RBEIntroViewController {

    class ErrorState: BaseErrorState {

        enum Strings {
            static let errorTitle = LocalizedString("alert.error.title", comment: "Error")
            static let errorOK = LocalizedString("alert.error.ok", comment: "OK")
        }

        override func didEnter(controller: RBEIntroViewController) {
            controller.present(makeAlert(), animated: true, completion: nil)
            controller.stopIndicateLoading()
            controller.showRetry()
            controller.enableRetry()
        }

        private func makeAlert() -> UIViewController {
            let alert = UIAlertController(title: Strings.errorTitle,
                                          message: error.localizedDescription,
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: Strings.errorOK, style: .default, handler: nil)
            alert.addAction(okAction)
            return alert
        }

    }

}
