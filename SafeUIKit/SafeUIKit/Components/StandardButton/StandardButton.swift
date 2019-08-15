//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

/// A button used throughout the app. When you use this button in Storyboard or Xib,
/// remember to make the button type 'Custom', otherwise it will have wrong behavior.
final public class StandardButton: BaseCustomButton {

    public enum Style {

        /// Similar to system plain button - only text.
        case plain

        /// Button with border around the text, with transparent background.
        case bordered

        /// Button with a solid color background.
        case filled

        // Each style has a set of title colors and background images for every useful UIControl state.
        //
        // This is implemented using tuples to be able to compile-check presense of colors and images for
        // each button state, for each style. Alternative implementation would be to use dictionary with
        // colors and images as arrays and runtime-check the presence of values with `guard` and `assert()`.
        //
        // Each image is a same-size file of a rounded rectangle with shadow. Make sure the
        // image's alignment margins are set in the Asset Catalog, as well as
        // slicing of the rounded corners.
        private static let styleSheet: StyleSheet = (

            plain: (colors: (normal: ColorName.hold.color,
                             highlighted: ColorName.holdDark.color,
                             disabled: ColorName.hold50.color),

                    images: (normal: nil, highlighted: nil, disabled: nil)),

            bordered: (colors: (normal: ColorName.darkBlue.color,
                                highlighted: ColorName.darkBlue70.color,
                                disabled: ColorName.darkBlue50.color),

                       images: (normal: Asset.BorderedButton.borderedNormal.image,
                                highlighted: Asset.BorderedButton.borderedPressed.image,
                                disabled: Asset.BorderedButton.borderedInactive.image)),

            filled: (colors: (normal: ColorName.snowwhite.color,
                              highlighted: ColorName.snowwhite.color,
                              disabled: ColorName.snowwhite50.color),

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

    /// Button's appearance. Default is `bordered`
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
        setNeedsLayout()
        layoutIfNeeded()
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
