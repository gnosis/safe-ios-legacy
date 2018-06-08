//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

extension UIView {

    /// Load contents of xib file with same name as caller type into the view of caller.
    func safeUIKit_loadFromNib() {
        let bundle = Bundle(for: type(of: self) as AnyClass)
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let contents = nib.instantiate(withOwner: self)
        contents.compactMap { $0 as? UIView }.forEach { subview in
            subview.frame = self.bounds
            subview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.addSubview(subview)
        }
    }

}
