//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

extension UITextField {

    var isIntegerField: Bool {
        return tag == TokenDoubleInput.Field.integer.rawValue
    }

    var isFractionalField: Bool {
        return tag == TokenDoubleInput.Field.fractional.rawValue
    }

    var nonNilText: String {
        return text ?? ""
    }

}
