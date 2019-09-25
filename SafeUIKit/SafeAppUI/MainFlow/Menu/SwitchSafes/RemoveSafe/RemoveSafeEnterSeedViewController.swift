//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

class RemoveSafeEnterSeedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(SafesTrackingEvent.removeSafeEnterSeed)
    }

}
