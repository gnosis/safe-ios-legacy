//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

class SeedWordCollectionViewCell: UICollectionViewCell {

    enum CellStyle {
        case normal
        case filled
        case empty
        case entered
        case error
    }

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var badgeImageView: UIImageView!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var backgroundButton: UIButton!

    var cellStyle: CellStyle = .normal {
        didSet {
            update()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = false
        
        numberLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        numberLabel.textAlignment = .center

        wordLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        wordLabel.textAlignment = .center
        wordLabel.adjustsFontSizeToFitWidth = true
        wordLabel.minimumScaleFactor = 0.5
        update()
    }

    func setWord(_ word: String?, number: Int?, style: CellStyle) {
        wordLabel.text = word
        numberLabel.text = number != nil ? String(number!) : nil
        cellStyle = style
    }

    // swiftlint:disable operator_usage_whitespace
    func update() {
        switch cellStyle {
        case .normal:
            numberLabel.textColor = ColorName.darkBlue.color
            badgeImageView.image = Asset.seedBadgeNormal.image
            wordLabel.textColor = ColorName.hold.color
            backgroundImage = Asset.seedBgNormal.image
        case .filled:
            numberLabel.textColor = ColorName.darkBlue.color
            badgeImageView.image = Asset.seedBadgeNormal.image
            wordLabel.textColor = ColorName.hold.color
            backgroundImage = Asset.seedBgFilled.image
        case .empty:
            numberLabel.textColor = ColorName.darkBlue.color
            badgeImageView.image = Asset.seedBadgeNormal.image
            wordLabel.textColor = ColorName.hold.color
            backgroundImage = Asset.seedBgEmpty.image
        case .entered:
            numberLabel.textColor = ColorName.darkBlue.color
            badgeImageView.image = Asset.seedBadgeNormal.image
            wordLabel.textColor = ColorName.darkGrey.color
            backgroundImage = Asset.seedBgFilled.image
        case .error:
            numberLabel.textColor = ColorName.snowwhite.color
            badgeImageView.image = Asset.seedBadgeError.image
            wordLabel.textColor = ColorName.tomato.color
            backgroundImage = Asset.seedBgError.image
        }
    }

    private var backgroundImage: UIImage? {
        didSet {
            backgroundButton.setBackgroundImage(backgroundImage, for: .normal)
        }
    }
}
