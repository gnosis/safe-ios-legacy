//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

private var TestHandlerHandle: UInt8 = 0

public extension UIAlertAction {

    static func create(title: String?,
                       style: UIAlertAction.Style,
                       handler: @escaping (UIAlertAction) -> Void) -> UIAlertAction {
        let action = UIAlertAction(title: title, style: style, handler: handler)
        #if DEBUG
        action.test_handler = handler
        #endif
        return action
    }

    #if DEBUG
    @objc var test_handler: ((UIAlertAction) -> Void)? {
        get {
            return objc_getAssociatedObject(self, &TestHandlerHandle) as? (UIAlertAction) -> Void
        }
        set {
            objc_setAssociatedObject(self,
                                     &TestHandlerHandle,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    #endif

}
