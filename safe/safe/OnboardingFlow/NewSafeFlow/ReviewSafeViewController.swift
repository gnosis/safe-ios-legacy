//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

class ReviewSafeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let label = UILabel()
        label.text = "Mock Review Safe View Controller"
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.center = view.center
    }

}
