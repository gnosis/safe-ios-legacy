//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public final class CheckmarkButton: UIButton {

    public enum CheckmarkStatus {
        case disabled
        case normal
        case selected
    }

    public var checkmarkStatus: CheckmarkStatus = .disabled {
        didSet {
            updateCheckmark()
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configure()
    }

    private func configure() {
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        imageEdgeInsets = UIEdgeInsets(top: 1, left: 0, bottom: -1, right: 0)
        titleLabel?.font = UIFont.systemFont(ofSize: 26)
    }

    private func updateCheckmark() {
        setImage(checkmarkImage(), for: .normal)
        accessibilityValue = localizedValue()
    }

    private func localizedValue() -> String? {
        switch checkmarkStatus {
        case .selected: return LocalizedString("button.checked", comment: "Checkmark is checked")
        case .normal: return LocalizedString("button.unchecked", comment: "Checkmark is not checked")
        case .disabled: return nil
        }
    }

    private func checkmarkImage() -> UIImage? {
        switch checkmarkStatus {
        case .selected: return Asset.checkmarkSelected.image
        case .normal: return Asset.checkmarkNormal.image
        case .disabled: return nil
        }
    }

}
