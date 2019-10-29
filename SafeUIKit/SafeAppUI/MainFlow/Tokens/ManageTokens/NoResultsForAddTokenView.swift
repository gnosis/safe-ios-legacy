//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class NoResultsForAddTokenView: UIView {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var getInTouchButton: StandardButton!

    var onGetInTouch: (() -> Void)?

    @IBAction func getInTouch(_ sender: Any) {
        onGetInTouch?()
    }

    enum Strings {
        static let header = LocalizedString("no_results_found", comment: "No results found")
        static let description = LocalizedString("missing_token_get_in_touch",
                                                 comment: "Missing a token description.")
        static let getInTouch = LocalizedString("get_in_touch", comment: "Get In Touch")
    }

    static func create() -> NoResultsForAddTokenView {
        return Bundle(for: NoResultsForAddTokenView.self)
            .loadNibNamed(
                "NoResultsForAddTokenView", owner: nil, options: nil)!.first! as! NoResultsForAddTokenView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        headerLabel.text = Strings.header
        headerLabel.textColor = ColorName.darkBlue.color
        descriptionLabel.text = Strings.description
        descriptionLabel.textColor = ColorName.darkGrey.color
        getInTouchButton.setTitle(Strings.getInTouch, for: .normal)
        getInTouchButton.style = .plain
    }

}
