//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

extension CABasicAnimation {

    static func shake(center: CGPoint) -> CABasicAnimation {
        let amplitude: CGFloat = 8
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.09
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.fromValue = CGPoint(x: center.x - amplitude, y: center.y)
        animation.toValue = CGPoint(x: center.x + amplitude, y: center.y)
        return animation
    }

}
