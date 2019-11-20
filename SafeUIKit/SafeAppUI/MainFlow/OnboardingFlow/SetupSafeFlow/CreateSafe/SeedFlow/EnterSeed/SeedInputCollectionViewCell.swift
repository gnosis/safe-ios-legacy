//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

class SeedInputCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var wordButton: UIButton!

    var word: SeedWord? {
        didSet {
            update()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = false

        wordButton.setTitleColor(ColorName.darkGrey.color, for: .normal)
        wordButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        wordButton.isUserInteractionEnabled = false
    }

    func update() {
        wordButton.setTitle(word?.value, for: .normal)
        guard let word = word else { return }
        switch word.style {
        case .normal:
            wordButton.setBackgroundImage(Asset.seedInputNormal.image, for: .normal)
        default:
            wordButton.setBackgroundImage(Asset.seedInputSelected.image, for: .normal)
            wordButton.setTitle(nil, for: .normal)
        }
    }

}
