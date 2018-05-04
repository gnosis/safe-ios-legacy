//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
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

    private struct Strings {
        static let header = LocalizedString("onboarding.start.header", comment: "App name")
        static let description = LocalizedString("onboarding.start.description", comment: "App slogan")
        static let start = LocalizedString("onboarding.start.start", comment: "Start button title")
    }

    static func create(delegate: StartViewControllerDelegate) -> StartViewController {
        let vc = StoryboardScene.MasterPassword.startViewController.instantiate()
        vc.delegate = delegate
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.text = Strings.header
        descriptionLabel.text = Strings.description
        startButton.setTitle(Strings.start, for: .normal)
    }

    @IBAction func start(_ sender: Any) {
        delegate?.didStart()
    }

}
