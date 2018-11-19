//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import BlockiesSwift

extension UIImage {

    static func createBlockiesImage(seed: String) -> UIImage {
        let blockies = Blockies(seed: seed,
                                size: 15,
                                scale: 3)
        return blockies.createImage(customScale: 3)!
    }

}
