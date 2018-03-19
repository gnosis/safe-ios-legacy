//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

class SetupSafeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let label = UILabel(frame: .init(x: 20, y: 40, width: view.frame.width - 20, height: 50))
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.text = NSLocalizedString("onboarding.setup_safe.info", comment: "Setup safe info label")
        view.addSubview(label)
    }

}
