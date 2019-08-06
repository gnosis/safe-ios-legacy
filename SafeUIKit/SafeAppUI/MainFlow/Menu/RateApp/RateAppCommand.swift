//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import StoreKit
import Common

final class RateAppCommand: MenuCommand {

    override var title: String {
        return LocalizedString("rate_app", comment: "Rate App").capitalized
    }

    override func run(mainFlowCoordinator: MainFlowCoordinator) {
        Tracker.shared.track(event: MenuTrackingEvent.rateApp)
        SKStoreReviewController.requestReview()
    }

}
