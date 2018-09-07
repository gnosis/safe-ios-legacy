//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import BlockiesSwift

extension UIImage {

    static func createBlockiesImage(seed: String) -> UIImage {
        let blockies = Blockies(seed: seed,
                                size: 8,
                                scale: 5)
        return blockies.createImage(customScale: 3)!
    }

}
