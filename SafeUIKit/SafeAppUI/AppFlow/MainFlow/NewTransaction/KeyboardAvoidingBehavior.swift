//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit

class KeyboardAvoidingBehavior {

    private weak var scrollView: UIScrollView!
    private let notificationCenter: NotificationCenter

    /// Set this variable to reference active text field when a text field gets focus
    var activeTextField: UITextField?

    init(scrollView: UIScrollView, notificationCenter: NotificationCenter = NotificationCenter.default) {
        self.scrollView = scrollView
        self.notificationCenter = notificationCenter
        let touchRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapScrollView))
        scrollView.gestureRecognizers?.forEach { touchRecognizer.require(toFail: $0) }
        scrollView.addGestureRecognizer(touchRecognizer)
    }

    func start() {
        notificationCenter.addObserver(self,
                                       selector: #selector(didShowKeyboard(_:)),
                                       name: UIResponder.keyboardDidShowNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(didHideKeyboard(_:)),
                                       name: UIResponder.keyboardWillHideNotification,
                                       object: nil)

    }

    func stop() {
        notificationCenter.removeObserver(self, name: nil, object: nil)
    }

    @objc func didTapScrollView() {
        if let field = activeTextField {
            deactivateField(field)
        }
    }

    @objc func didShowKeyboard(_ notification: NSNotification) {
        guard let view = scrollView.superview else { return }
        guard let screenValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardScreen = screenValue.cgRectValue
        let keyboardFrame = view.convert(keyboardScreen, from: UIScreen.main.coordinateSpace)
        scrollView.contentInset.bottom = keyboardFrame.height
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        var rect = view.frame
        rect.size.height -= keyboardFrame.height
        if let field = activeTextField, !rect.contains(field.frame.origin) {
            var animated = true
            if let isSuppressing = notification.userInfo?["suppress_animation"] as? Bool {
                animated = !isSuppressing
            }
            scrollView.scrollRectToVisible(field.frame, animated: animated)
        }
    }

    @objc func didHideKeyboard(_ notification: NSNotification) {
        scrollView.contentInset.bottom = 0
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }

    func activateField(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }

    func deactivateField(_ textField: UITextField) {
        textField.resignFirstResponder()
    }

}
