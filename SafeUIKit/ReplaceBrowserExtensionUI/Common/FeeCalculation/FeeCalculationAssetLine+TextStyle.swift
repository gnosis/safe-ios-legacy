//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

extension FeeCalculationAssetLine {

    struct TextStyle {
        var name: AttributedStringStyle
        var value: AttributedStringStyle
        var info: AttributedStringStyle
        var error: AttributedStringStyle

        static let plain = TextStyle(name: DefaultStyle(),
                                     value: ValueStyle(),
                                     info: NameButtonStyle(),
                                     error: ErrorStyle())

        static let balance = TextStyle(name: NameBalanceStyle(),
                                       value: ValueBalanceStyle(),
                                       info: NameButtonBalanceStyle(),
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

    class NameButtonBalanceStyle: NameButtonStyle {

        override var fontWeight: UIFont.Weight { return .bold }

    }

    class ValueStyle: DefaultStyle {

        override var alignment: NSTextAlignment { return .right }

    }

    class ValueBalanceStyle: ValueStyle {

        override var fontWeight: UIFont.Weight { return .bold }

    }

    class ErrorStyle: DefaultStyle {

        override var fontColor: UIColor { return ColorName.tomato.color }

    }

    class ErrorBalanceStyle: ValueBalanceStyle {

        override var fontColor: UIColor { return ColorName.tomato.color }

    }

}
