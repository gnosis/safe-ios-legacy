//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

class ConnectAuthenticatorSuccessViewController: HeaderImageTextStepController {

    static func create(onNext: @escaping () -> Void) -> HeaderImageTextStepController {
        return HeaderImageTextStepController.create(
            title: LocalizedString("pair_2FA_device", comment: "Pair 2FA device"),
            threeStepsState: .pair2FA_paired,
            header: LocalizedString("safe_authenticator_paired", comment: "Authenticator successfully paired"),
            image: Asset.CreateSafe.connectBrowserExtension.image,
            text: LocalizedString("authenticator_paired_description", comment: "Authenticator paired description"),
            trackingEvent: CreateSafeTrackingEvent.connectAuthenticatorSuccess,
            onNext: onNext)
    }

}
