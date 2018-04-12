//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import IdentityAccessDomainModel

final class CountdownLabel: UILabel {

    private var time: TimeInterval = 0
    private var clockService: Clock?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        isHidden = true
    }

    func setup(time: TimeInterval, clock: Clock) {
        self.time = time
        self.clockService = clock
    }

    func start(completion: @escaping () -> Void) {
        guard let clock = clockService else {
            completion()
            return
        }
        isHidden = false
        clock.countdown(from: time) { [weak self] remainingTime in
            guard let `self` = self else { return }
            self.text = String(format: "00:%02.0f", remainingTime)
            if remainingTime == 0 {
                self.isHidden = true
                completion()
            }
        }
    }

}
