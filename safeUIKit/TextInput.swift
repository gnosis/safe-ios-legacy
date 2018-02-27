//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

public final class TextInput: UIView {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var stackView: UIStackView!

    override public func awakeFromNib() {
        super.awakeFromNib()
    }

    public static func create() -> TextInput {
        let bundle = Bundle(for: TextInput.self)
        let nib = UINib(nibName: "TextInput", bundle: bundle)
        let contents = nib.instantiate(withOwner: nil)
        return contents.first as! TextInput
    }

}
