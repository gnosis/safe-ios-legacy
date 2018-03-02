//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

protocol StartViewControllerDelegate: class {
    func didStart()
}

final class StartViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    private weak var delegate: StartViewControllerDelegate?

    static func create(delegate: StartViewControllerDelegate) -> StartViewController {
        let vc = StoryboardScene.MasterPassword.startViewController.instantiate()
        vc.delegate = delegate
        return vc
    }

    @IBAction func start(_ sender: Any) {
        delegate?.didStart()
    }

}
