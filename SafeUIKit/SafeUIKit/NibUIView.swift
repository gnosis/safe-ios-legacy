//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit

open class NibUIView: UIView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    open func commonInit() {
        let aClass = type(of: self)
        guard let contents = Bundle(for: aClass).loadNibNamed("\(aClass)", owner: self, options: nil),
            let contentView = contents.first as? UIView else { return }
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        setUpConstraints(for: contentView)
        didLoad()
    }

    open func setUpConstraints(for contentView: UIView) {
        NSLayoutConstraint.activate([widthAnchor.constraint(equalTo: contentView.widthAnchor),
                                     heightAnchor.constraint(equalTo: contentView.heightAnchor)])
    }

    open func didLoad() {
        // meant for subclassing
    }

}
