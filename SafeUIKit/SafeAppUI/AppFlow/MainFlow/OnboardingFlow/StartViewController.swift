//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import Common

protocol StartViewControllerDelegate: class {
    func didStart()
}

final class StartViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: BackgroundImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var setupPasswordButton: StandardButton!
    private weak var delegate: StartViewControllerDelegate!

    private var preservedNavBarColor: UIColor!
    private var preservedTranslucent: Bool!

    private enum Strings {
        static let description = LocalizedString("app_slogan", comment: "App slogan")
        static let setupPassword = LocalizedString("setup_password", comment: "Set up password button title")
    }

    static func create(delegate: StartViewControllerDelegate) -> StartViewController {
        let vc = StoryboardScene.MasterPassword.startViewController.instantiate()
        vc.delegate = delegate
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionLabel.text = Strings.description
        setupPasswordButton.setTitle(Strings.setupPassword, for: .normal)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(OnboardingEvent.welcome)
        trackEvent(OnboardingTrackingEvent.welcome)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        preservedNavBarColor = navigationController!.navigationBar.barTintColor
        preservedTranslucent = navigationController!.navigationBar.isTranslucent
        navigationController!.navigationBar.barTintColor = .clear
        navigationController!.navigationBar.isTranslucent = true
        navigationController!.navigationBar.shadowImage = UIImage()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.barTintColor = preservedNavBarColor
        if let preservedTranslucent = preservedTranslucent {
            navigationController?.navigationBar.isTranslucent = preservedTranslucent
        }
        navigationController?.navigationBar.shadowImage = Asset.shadow.image
    }

    @IBAction func setupPassword(_ sender: Any) {
        delegate.didStart()
    }

}
