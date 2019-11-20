// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Storyboard Scenes

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
internal enum StoryboardScene {
  internal enum ChangePassword: StoryboardType {
    internal static let storyboardName = "ChangePassword"

    internal static let setupNewPasswordViewController = SceneType<SafeAppUI.SetupNewPasswordViewController>(storyboard: ChangePassword.self, identifier: "SetupNewPasswordViewController")

    internal static let verifyCurrentPasswordViewController = SceneType<SafeAppUI.VerifyCurrentPasswordViewController>(storyboard: ChangePassword.self, identifier: "VerifyCurrentPasswordViewController")
  }
  internal enum CreateSafe: StoryboardType {
    internal static let storyboardName = "CreateSafe"

    internal static let onboardingIntroViewController = SceneType<SafeAppUI.OnboardingIntroViewController>(storyboard: CreateSafe.self, identifier: "OnboardingIntroViewController")

    internal static let skActivateViewController = SceneType<SafeAppUI.SKActivateViewController>(storyboard: CreateSafe.self, identifier: "SKActivateViewController")

    internal static let skPairViewController = SceneType<SafeAppUI.SKPairViewController>(storyboard: CreateSafe.self, identifier: "SKPairViewController")

    internal static let skSignWithPinViewController = SceneType<SafeAppUI.SKSignWithPinViewController>(storyboard: CreateSafe.self, identifier: "SKSignWithPinViewController")
  }
  internal enum Main: StoryboardType {
    internal static let storyboardName = "Main"

    internal static let addTokenNavigationController = SceneType<UIKit.UINavigationController>(storyboard: Main.self, identifier: "AddTokenNavigationController")

    internal static let addTokenTableViewController = SceneType<SafeAppUI.AddTokenTableViewController>(storyboard: Main.self, identifier: "AddTokenTableViewController")

    internal static let ensInputViewController = SceneType<SafeAppUI.ENSInputViewController>(storyboard: Main.self, identifier: "ENSInputViewController")

    internal static let mainNavigationController = SceneType<UIKit.UINavigationController>(storyboard: Main.self, identifier: "MainNavigationController")

    internal static let mainViewController = SceneType<SafeAppUI.MainViewController>(storyboard: Main.self, identifier: "MainViewController")

    internal static let menuTableViewController = SceneType<SafeAppUI.MenuTableViewController>(storyboard: Main.self, identifier: "MenuTableViewController")

    internal static let sendInputViewController = SceneType<SafeAppUI.SendInputViewController>(storyboard: Main.self, identifier: "SendInputViewController")

    internal static let successViewController = SceneType<SafeAppUI.SuccessViewController>(storyboard: Main.self, identifier: "SuccessViewController")

    internal static let transactionDetailsViewController = SceneType<SafeAppUI.TransactionDetailsViewController>(storyboard: Main.self, identifier: "TransactionDetailsViewController")

    internal static let transactionsTableViewController = SceneType<SafeAppUI.TransactionViewViewController>(storyboard: Main.self, identifier: "TransactionsTableViewController")
  }
  internal enum MasterPassword: StoryboardType {
    internal static let storyboardName = "MasterPassword"

    internal static let onboardingTermsViewController = SceneType<SafeAppUI.OnboardingTermsViewController>(storyboard: MasterPassword.self, identifier: "OnboardingTermsViewController")

    internal static let onboardingWelcomeViewController = SceneType<SafeAppUI.OnboardingWelcomeViewController>(storyboard: MasterPassword.self, identifier: "OnboardingWelcomeViewController")
  }
  internal enum RecoverSafe: StoryboardType {
    internal static let storyboardName = "RecoverSafe"

    internal static let addressInputViewController = SceneType<SafeAppUI.AddressInputViewController>(storyboard: RecoverSafe.self, identifier: "AddressInputViewController")

    internal static let recoveryPhraseInputViewController = SceneType<SafeAppUI.RecoveryPhraseInputViewController>(storyboard: RecoverSafe.self, identifier: "RecoveryPhraseInputViewController")
  }
  internal enum SeedPhrase: StoryboardType {
    internal static let storyboardName = "SeedPhrase"

    internal static let enterSeedViewController = SceneType<SafeAppUI.EnterSeedViewController>(storyboard: SeedPhrase.self, identifier: "EnterSeedViewController")

    internal static let showSeedViewController = SceneType<SafeAppUI.ShowSeedViewController>(storyboard: SeedPhrase.self, identifier: "ShowSeedViewController")
  }
  internal enum SetupSafe: StoryboardType {
    internal static let storyboardName = "SetupSafe"

    internal static let setupSafeOptionsViewController = SceneType<SafeAppUI.OnboardingCreateOrRestoreViewController>(storyboard: SetupSafe.self, identifier: "SetupSafeOptionsViewController")
  }
  internal enum Unlock: StoryboardType {
    internal static let storyboardName = "Unlock"

    internal static let unlockViewController = SceneType<SafeAppUI.UnlockViewController>(storyboard: Unlock.self, identifier: "UnlockViewController")
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

// MARK: - Implementation Details

internal protocol StoryboardType {
  static var storyboardName: String { get }
}

internal extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: Bundle(for: BundleToken.self))
  }
}

internal struct SceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type
  internal let identifier: String

  internal func instantiate() -> T {
    let identifier = self.identifier
    guard let controller = storyboard.storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
      fatalError("ViewController '\(identifier)' is not of the expected class \(T.self).")
    }
    return controller
  }
}

internal struct InitialSceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type

  internal func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }
}

private final class BundleToken {}
