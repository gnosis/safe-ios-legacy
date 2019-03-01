//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

enum OnboardingEvent: String, Trackable {

    case welcome = "onboarding_welcome"
    case terms = "onboarding_terms"
    case setPassword = "onboarding_set-password"
    case confirmPassword = "onboarding_confirm-password"
    case newOrRecover = "onboarding_new-or-recover"
    case guidelines = "onboarding_recovery-intro"
    case recoveryPhrase = "onboarding_show-seed"
    case confirmRecovery = "onboarding_enter-seed"
    case configure = "onboarding_configure"
    case addBrowserExtension = "onboarding_2fa"
    case browserExtensionAdded = "onboarding_2fa-configured"
    case createSafe = "onboarding_creation-fee"
    case safeFeePaid = "onboarding_fee-paid"

}
