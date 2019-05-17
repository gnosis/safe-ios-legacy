//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

extension FeeCalculationAssetLine {

    struct TextStyle {
        var name: AttributedStringStyle
        var value: AttributedStringStyle
        var valueError: AttributedStringStyle
        var valueButton: AttributedStringStyle
        var valueButtonPressed: AttributedStringStyle
        var info: AttributedStringStyle
        var infoPressed: AttributedStringStyle
        var error: AttributedStringStyle

        static let plain = TextStyle(name: DefaultStyle(),
                                     value: ValueStyle(),
                                     valueError: ValueErrorStyle(),
                                     valueButton: ValueButtonStyle(),
                                     valueButtonPressed: ValueButtonPressedStyle(),
                                     info: NameButtonStyle(),
                                     infoPressed: NameButtonPressedStyle(),
                                     error: ErrorStyle())

        static let balance = TextStyle(name: NameBalanceStyle(),
                                       value: ValueBalanceStyle(),
                                       valueError: ValueBalanceErrorStyle(),
                                       valueButton: ValueButtonStyle(),
                                       valueButtonPressed: ValueButtonPressedStyle(),
                                       info: NameButtonBalanceStyle(),
                                       infoPressed: NameButtonBalancePressedStyle(),
                                       error: ErrorBalanceStyle())
    }

    class DefaultStyle: AttributedStringStyle {

        override var fontSize: Double { return 16 }
        override var minimumLineHeight: Double { return 25 }
        override var maximumLineHeight: Double { return 25 }
        override var fontColor: UIColor { return ColorName.battleshipGrey.color }

    }

    class NameBalanceStyle: DefaultStyle {

        override var fontWeight: UIFont.Weight { return .bold }

    }

    class NameButtonStyle: DefaultStyle {

        override var fontColor: UIColor { return ColorName.aquaBlue.color }

    }

    class NameButtonPressedStyle: NameButtonStyle {

        override var fontColor: UIColor { return .darkText }

    }

    class NameButtonBalanceStyle: NameButtonStyle {

        override var fontWeight: UIFont.Weight { return .bold }

    }

    class NameButtonBalancePressedStyle: NameButtonBalanceStyle {

        override var fontColor: UIColor { return .darkText }

    }

    class ValueStyle: DefaultStyle {

        override var alignment: NSTextAlignment { return .right }

    }

    class ValueErrorStyle: ValueStyle {

        override var fontColor: UIColor { return ColorName.tomato.color }

    }

    class ValueButtonStyle: NameButtonStyle {

        override var minimumLineHeight: Double { return 20 }
        override var maximumLineHeight: Double { return 20 }

    }

    class ValueButtonPressedStyle: ValueButtonStyle {

        override var fontColor: UIColor { return UIColor.darkText }

    }

    class ValueBalanceStyle: ValueStyle {

        override var fontWeight: UIFont.Weight { return .bold }

    }

    class ValueBalanceErrorStyle: ValueBalanceStyle {

        override var fontColor: UIColor { return ColorName.tomato.color }

    }

    class ErrorStyle: DefaultStyle {

        override var fontColor: UIColor { return ColorName.tomato.color }

    }

    class ErrorBalanceStyle: ValueBalanceStyle {

        override var fontColor: UIColor { return ColorName.tomato.color }

    }

}
