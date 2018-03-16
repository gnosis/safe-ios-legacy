//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

final class CountdownLabel: UILabel {

    private var time: TimeInterval = 0
    private var clockService: SystemClockServiceProtocol?

    override func awakeFromNib() {
        super.awakeFromNib()
        isHidden = true
    }

    func setup(time: TimeInterval, clock: SystemClockServiceProtocol) {
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
