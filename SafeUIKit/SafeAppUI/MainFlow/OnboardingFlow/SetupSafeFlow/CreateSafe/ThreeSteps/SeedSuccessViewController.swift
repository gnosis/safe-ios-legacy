//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class SeedSuccessViewController: HeaderImageTextStepController {

    static func create(state: ThreeStepsView.State, onNext: @escaping () -> Void) -> HeaderImageTextStepController {
        return HeaderImageTextStepController.create(
            title: LocalizedString("recovery_phrase", comment: "Recovery phrase"),
            threeStepsState: state,
            header: LocalizedString("recovery_phrase_backed_up", comment: "Recovery phrase backed up"),
            image: Asset.CreateSafe.backupPhrase.image,
            text: LocalizedString("you_can_replace_phrase_anytime", comment: "You can replace your phrase"),
            trackingEvent: CreateSafeTrackingEvent.seedIntro,
            onNext: onNext)
    }

}
