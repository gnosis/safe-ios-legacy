//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

protocol StartViewControllerDelegate: class {
    func didStart()
}

final class StartViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: BackgroundImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var setupPasswordButton: BigBorderedButton!
    private weak var delegate: StartViewControllerDelegate?

    private var preservedNavBarColor: UIColor!
    private var preservedTranslucent: Bool!

    private struct Strings {
        static let description = LocalizedString("onboarding.start.description", comment: "App slogan")
        static let setupPassword = LocalizedString("onboarding.start.setup_password",
                                                   comment: "Setup password button title")
    }

    static func create(delegate: StartViewControllerDelegate) -> StartViewController {
        let vc = StoryboardScene.MasterPassword.startViewController.instantiate()
        vc.delegate = delegate
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImageView.isDark = true
        descriptionLabel.text = Strings.description
        setupPasswordButton.setTitle(Strings.setupPassword, for: .normal)
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
        navigationController?.navigationBar.shadowImage = nil
    }

    @IBAction func setupPassword(_ sender: Any) {
        delegate?.didStart()
    }

}
