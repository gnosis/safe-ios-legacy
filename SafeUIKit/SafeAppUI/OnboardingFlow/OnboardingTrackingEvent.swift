//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

/// Tracking events occuring during onboarding flows.
@available(*, deprecated, message: "Please use OnboardingTrackingEvent instead")
enum OnboardingEvent: String, Trackable {

    // These events are still used for funnel testing. They will be removed.
    case welcome                = "Onboarding_Welcome"
    case setPassword            = "Onboarding_SetPassword"
    case confirmPassword        = "Onboarding_ConfirmPassword"
    case guidelines             = "Onboarding_RecoveryIntro"
    case recoveryPhrase         = "Onboarding_ShowSeed"
    case confirmRecovery        = "Onboarding_EnterSeed"
    case configure              = "Onboarding_Configure"
    case createSafe             = "Onboarding_CreationFee"
    case safeFeePaid            = "Onboarding_FeePaid"

    // These events are not for use anymore.
    case terms                  = "Onboarding_Terms"
    case newOrRecover           = "Onboarding_CreateOrRestore"
    case addBrowserExtension    = "Onboarding_2FA"
    case scanQR                 = "Onboarding_2FAScan"
    case browserExtensionAdded  = "Onboarding_2FAScanSuccess"

}

enum OnboardingTrackingEvent: String, ScreenTrackingEvent {

    case welcome                = "Onboarding_Welcome"
    case terms                  = "Onboarding_Terms"
    case setPassword            = "Onboarding_SetPassword"
    case confirmPassword        = "Onboarding_ConfirmPassword"
    case createOrRestore        = "Onboarding_CreateOrRestore"
    case recoveryIntro          = "Onboarding_RecoveryIntro"
    case showSeed               = "Onboarding_ShowSeed"
    case enterSeed              = "Onboarding_EnterSeed"
    case configure              = "Onboarding_Configure"
    case twoFA                  = "Onboarding_2FA"
    case twoFAScan              = "Onboarding_2FAScan"
    case twoFAScanSuccess       = "Onboarding_2FAScanSuccess"
    case twoFAScanError         = "Onboarding_2FAScanError"
    case creationFee            = "Onboarding_CreationFee"
    case feePaid                = "Onboarding_FeePaid"

}
