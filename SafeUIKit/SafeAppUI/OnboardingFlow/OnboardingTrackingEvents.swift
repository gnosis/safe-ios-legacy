//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

enum OnboardingEvent: String, Trackable {

    case welcome = "Onboarding_Welcome"
    case terms = "Onboarding_Terms"
    case setPassword = "Onboarding_SetPassword"
    case confirmPassword = "Onboarding_ConfirmPassword"
    case newOrRecover = "Onboarding_CreateOrRestore"
    case guidelines = "Onboarding_RecoveryIntro"
    case recoveryPhrase = "Onboarding_ShowSeed"
    case confirmRecovery = "Onboarding_EnterSeed"
    case configure = "Onboarding_Configure"
    case addBrowserExtension = "Onboarding_2FA"
    case scanQR = "Onboarding_2FAScan"
    case browserExtensionAdded = "Onboarding_2FASuccess"
    case createSafe = "Onboarding_CreationFee"
    case safeFeePaid = "Onboarding_FeePaid"

}
