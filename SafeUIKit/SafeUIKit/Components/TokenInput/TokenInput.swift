//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public final class TokenInput: VerifiableInput {

    enum Strings {
        static let amount = LocalizedString("token_input.amount", comment: "Amount placeholder for token input.")
    }

    public var imageURL: URL? {
        didSet {
            textInput.leftImageURL = imageURL
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    private func commonInit() {
        textInput.placeholder = Strings.amount
        textInput.leftImage = Asset.TokenIcons.defaultToken.image
    }

}
