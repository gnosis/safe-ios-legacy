//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class SeedIntroViewController: HeaderImageTextStepController {

    static func create(state: ThreeStepsView.State, onNext: @escaping () -> Void) -> HeaderImageTextStepController {
        return HeaderImageTextStepController.create(
            title: LocalizedString("recovery_phrase", comment: "Recovery phrase"),
            threeStepsState: state,
            header: LocalizedString("backup_recovery", comment: "Backup your recovery phrase"),
            image: Asset.CreateSafe.backupPhrase.image,
            text: LocalizedString("use_the_phrase_on_the_next_screen", comment: "Recovery phrase description"),
            trackingEvent: CreateSafeTrackingEvent.seedIntro,
            onNext: onNext)
    }

}
