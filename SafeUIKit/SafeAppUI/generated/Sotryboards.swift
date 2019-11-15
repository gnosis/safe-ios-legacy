// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

protocol StoryboardType {
  static var storyboardName: String { get }
}

extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: Bundle(for: BundleToken.self))
  }
}

struct SceneType<T: Any> {
  let storyboard: StoryboardType.Type
  let identifier: String

  func instantiate() -> T {
    let identifier = self.identifier
    guard let controller = storyboard.storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
      fatalError("ViewController '\(identifier)' is not of the expected class \(T.self).")
    }
    return controller
  }
}

struct InitialSceneType<T: Any> {
  let storyboard: StoryboardType.Type

  func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }
}

protocol SegueType: RawRepresentable { }

extension UIViewController {
  func perform<S: SegueType>(segue: S, sender: Any? = nil) where S.RawValue == String {
    let identifier = segue.rawValue
    performSegue(withIdentifier: identifier, sender: sender)
  }
}

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
enum StoryboardScene {
  enum ChangePassword: StoryboardType {
    static let storyboardName = "ChangePassword"

    static let setupNewPasswordViewController = SceneType<SafeAppUI.SetupNewPasswordViewController>(storyboard: ChangePassword.self, identifier: "SetupNewPasswordViewController")

    static let verifyCurrentPasswordViewController = SceneType<SafeAppUI.VerifyCurrentPasswordViewController>(storyboard: ChangePassword.self, identifier: "VerifyCurrentPasswordViewController")
  }
  enum CreateSafe: StoryboardType {
    static let storyboardName = "CreateSafe"

    static let confirmMnemonicViewController = SceneType<SafeAppUI.ConfirmMnemonicViewController>(storyboard: CreateSafe.self, identifier: "ConfirmMnemonicViewController")

    static let onboardingIntroViewController = SceneType<SafeAppUI.OnboardingIntroViewController>(storyboard: CreateSafe.self, identifier: "OnboardingIntroViewController")

    static let skActivateViewController = SceneType<SafeAppUI.SKActivateViewController>(storyboard: CreateSafe.self, identifier: "SKActivateViewController")

    static let skPairViewController = SceneType<SafeAppUI.SKPairViewController>(storyboard: CreateSafe.self, identifier: "SKPairViewController")

    static let skSignWithPinViewController = SceneType<SafeAppUI.SKSignWithPinViewController>(storyboard: CreateSafe.self, identifier: "SKSignWithPinViewController")

    static let saveMnemonicViewController = SceneType<SafeAppUI.SaveMnemonicViewController>(storyboard: CreateSafe.self, identifier: "SaveMnemonicViewController")
  }
  enum Main: StoryboardType {
    static let storyboardName = "Main"

    static let addTokenNavigationController = SceneType<UINavigationController>(storyboard: Main.self, identifier: "AddTokenNavigationController")

    static let addTokenTableViewController = SceneType<SafeAppUI.AddTokenTableViewController>(storyboard: Main.self, identifier: "AddTokenTableViewController")

    static let ensInputViewController = SceneType<SafeAppUI.ENSInputViewController>(storyboard: Main.self, identifier: "ENSInputViewController")

    static let mainNavigationController = SceneType<UINavigationController>(storyboard: Main.self, identifier: "MainNavigationController")

    static let mainViewController = SceneType<SafeAppUI.MainViewController>(storyboard: Main.self, identifier: "MainViewController")

    static let menuTableViewController = SceneType<SafeAppUI.MenuTableViewController>(storyboard: Main.self, identifier: "MenuTableViewController")

    static let sendInputViewController = SceneType<SafeAppUI.SendInputViewController>(storyboard: Main.self, identifier: "SendInputViewController")

    static let successViewController = SceneType<SafeAppUI.SuccessViewController>(storyboard: Main.self, identifier: "SuccessViewController")

    static let transactionDetailsViewController = SceneType<SafeAppUI.TransactionDetailsViewController>(storyboard: Main.self, identifier: "TransactionDetailsViewController")

    static let transactionsTableViewController = SceneType<SafeAppUI.TransactionViewViewController>(storyboard: Main.self, identifier: "TransactionsTableViewController")
  }
  enum MasterPassword: StoryboardType {
    static let storyboardName = "MasterPassword"

    static let onboardingTermsViewController = SceneType<SafeAppUI.OnboardingTermsViewController>(storyboard: MasterPassword.self, identifier: "OnboardingTermsViewController")

    static let onboardingWelcomeViewController = SceneType<SafeAppUI.OnboardingWelcomeViewController>(storyboard: MasterPassword.self, identifier: "OnboardingWelcomeViewController")
  }
  enum RecoverSafe: StoryboardType {
    static let storyboardName = "RecoverSafe"

    static let addressInputViewController = SceneType<SafeAppUI.AddressInputViewController>(storyboard: RecoverSafe.self, identifier: "AddressInputViewController")

    static let recoveryPhraseInputViewController = SceneType<SafeAppUI.RecoveryPhraseInputViewController>(storyboard: RecoverSafe.self, identifier: "RecoveryPhraseInputViewController")
  }
  enum SetupSafe: StoryboardType {
    static let storyboardName = "SetupSafe"

    static let setupSafeOptionsViewController = SceneType<SafeAppUI.OnboardingCreateOrRestoreViewController>(storyboard: SetupSafe.self, identifier: "SetupSafeOptionsViewController")
  }
  enum Unlock: StoryboardType {
    static let storyboardName = "Unlock"

    static let unlockViewController = SceneType<SafeAppUI.UnlockViewController>(storyboard: Unlock.self, identifier: "UnlockViewController")
  }
}

enum StoryboardSegue {
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

private final class BundleToken {}
