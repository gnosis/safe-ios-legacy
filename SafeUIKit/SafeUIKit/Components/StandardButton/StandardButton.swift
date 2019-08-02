//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

final public class StandardButton: BaseCustomButton {

    public enum Style {
        case plain
        case bordered
        case filled

        // each style has a set of title colors and background images for every useful UIControl state.
        private static let styleSheet: StyleSheet = (

            plain: (colors: (normal: ColorName.hold.color,
                             highlighted: ColorName.darkBlue50.color,
                             disabled: ColorName.darkGrey.color),
                    images: (normal: nil, highlighted: nil, disabled: nil)),

            bordered: (colors: (normal: ColorName.darkBlue.color,
                                highlighted: ColorName.darkBlue50.color,
                                disabled: ColorName.darkBlue50.color),
                       images: (normal: nil, highlighted: nil, disabled: nil)),

            filled: (colors: (normal: ColorName.snowwhite.color,
                              highlighted: ColorName.white.color,
                              disabled: ColorName.white.color),
                     images: (normal: Asset.FilledButton.filledNormal.image,
                              highlighted: Asset.FilledButton.filledPressed.image,
                              disabled: Asset.FilledButton.filledInactive.image)))

        fileprivate var assets: StandardButton.AssetSet {
            switch self {
            case .plain: return StandardButton.Style.styleSheet.plain
            case .bordered: return StandardButton.Style.styleSheet.bordered
            case .filled: return StandardButton.Style.styleSheet.filled
            }
        }

    }

    fileprivate typealias StyleSheet = (plain: AssetSet, bordered: AssetSet, filled: AssetSet)
    fileprivate typealias AssetSet = (colors: ColorSet, images: ImageSet)
    fileprivate typealias ColorSet = (normal: UIColor?, highlighted: UIColor?, disabled: UIColor?)
    fileprivate typealias ImageSet = (normal: UIImage?, highlighted: UIImage?, disabled: UIImage?)

    public var style: Style = .bordered { didSet { update() } }
    private let titleFont = UIFont.systemFont(ofSize: 17, weight: .medium)

    public override func commonInit() {
        titleLabel?.font = titleFont
        adjustsImageWhenDisabled = false
        adjustsImageWhenHighlighted = false
        update()
    }

    public override func update() {
        setTitleColors(style.assets.colors)
        setBackgroundImages(style.assets.images)
    }

    fileprivate func setTitleColors(_ colors: ColorSet) {
        setTitleColor(colors.normal, for: .normal)
        setTitleColor(colors.highlighted, for: .highlighted)
        setTitleColor(colors.highlighted, for: [.highlighted, .selected])
        setTitleColor(colors.disabled, for: .disabled)
    }

    fileprivate func setBackgroundImages(_ images: ImageSet) {
        setBackgroundImage(images.normal, for: .normal)
        setBackgroundImage(images.highlighted, for: .highlighted)
        setBackgroundImage(images.highlighted, for: [.highlighted, .selected])
        setBackgroundImage(images.disabled, for: .disabled)
    }

}
