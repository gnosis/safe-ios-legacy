//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

class CBEIntroViewController: RBEIntroViewController {

    static func createConnectExtensionIntro() -> CBEIntroViewController {
        return CBEIntroViewController(nibName: "\(RBEIntroViewController.self)", bundle: Bundle(for: self))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setContent(.connectExtension)
    }

}

extension IntroContentView.Content {

    static let connectExtension = IntroContentView.Content(header: LocalizedString("connect_extension.intro.header",
                                                                                   comment: "Header label"),
                                                           body: LocalizedString("connect_extension.intro.body",
                                                                                 comment: "Body text"),
                                                           icon: Asset.ConnectBrowserExtension.connectIntroIcon.image)

}
