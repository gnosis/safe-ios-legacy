//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public extension UIView {

    /// Load contents of xib file with same name as caller type into the view of caller.
    func safeUIKit_loadFromNib(forClass _class: AnyClass) {
        let bundle = Bundle(for: _class)
        let nib = UINib(nibName: String(describing: _class), bundle: bundle)
        let contents = nib.instantiate(withOwner: self)
        contents.compactMap { $0 as? UIView }.forEach { subview in
            subview.frame = self.bounds
            subview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.addSubview(subview)
        }
    }

}
