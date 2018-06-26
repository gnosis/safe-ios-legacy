//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

final class WalletDateFormatter: DateFormatter {

    override init() {
        super.init()
        dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
