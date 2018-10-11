//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public final class TokenInput: VerifiableInput {

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
        // TODO
    }

}
