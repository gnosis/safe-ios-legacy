//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

extension BaseID: DBSerializable {

    public var serializedString: String {
        return id
    }

    convenience init?(serializedString: String?) {
        guard let string = serializedString else { return nil }
        self.init(string)
    }

}
