//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import Common

protocol OnboardingWelcomeViewControllerDelegate: class {
    func didStart()
}

final class OnboardingWelcomeViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: BackgroundImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var setupPasswordButton: StandardButton!
    private weak var delegate: OnboardingWelcomeViewControllerDelegate!

    // needed for navigation bar manipulations when this controller is removed from navigation controller
    private weak var _navigationController: UINavigationController!

    private enum Strings {
        static let description = LocalizedString("ios_app_slogan", comment: "App slogan")
        static let setupPassword = LocalizedString("setup_password", comment: "Set up password button title")
    }

    static func create(delegate: OnboardingWelcomeViewControllerDelegate) -> OnboardingWelcomeViewController {
        let vc = StoryboardScene.MasterPassword.onboardingWelcomeViewController.instantiate()
        vc.delegate = delegate
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionLabel.text = Strings.description
        descriptionLabel.font = UIFont(descriptor: UIFontDescriptor(name: "Averta-Regular", size: 26), size: 26)
        descriptionLabel.textColor = ColorName.darkBlue.color
        setupPasswordButton.setTitle(Strings.setupPassword, for: .normal)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(OnboardingEvent.welcome)
        trackEvent(OnboardingTrackingEvent.welcome)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _navigationController = navigationController
        _navigationController?.navigationBar.setBackgroundImage(Asset.navbarFilled.image, for: .default)
        _navigationController?.navigationBar.shadowImage = UIImage()
        _navigationController?.navigationBar.tintColor = ColorName.darkBlue.color
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        _navigationController?.navigationBar.shadowImage = Asset.shadow.image
        _navigationController?.navigationBar.tintColor = ColorName.hold.color
    }

    @IBAction func setupPassword(_ sender: Any) {
        delegate.didStart()
    }

}
