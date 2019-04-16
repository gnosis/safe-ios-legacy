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
  enum Main: StoryboardType {
    static let storyboardName = "Main"

    static let addTokenNavigationController = SceneType<UINavigationController>(storyboard: Main.self, identifier: "AddTokenNavigationController")

    static let addTokenTableViewController = SceneType<SafeAppUI.AddTokenTableViewController>(storyboard: Main.self, identifier: "AddTokenTableViewController")

    static let fundsTransferTransactionViewController = SceneType<SafeAppUI.FundsTransferTransactionViewController>(storyboard: Main.self, identifier: "FundsTransferTransactionViewController")

    static let mainViewController = SceneType<SafeAppUI.MainViewController>(storyboard: Main.self, identifier: "MainViewController")

    static let menuTableViewController = SceneType<SafeAppUI.MenuTableViewController>(storyboard: Main.self, identifier: "MenuTableViewController")

    static let replaceRecoveryPhraseViewController = SceneType<SafeAppUI.ReplaceRecoveryPhraseViewController>(storyboard: Main.self, identifier: "ReplaceRecoveryPhraseViewController")

    static let safeAddressViewController = SceneType<SafeAppUI.SafeAddressViewController>(storyboard: Main.self, identifier: "SafeAddressViewController")

    static let safeNavigationController = SceneType<SafeAppUI.SafeNavigationController>(storyboard: Main.self, identifier: "SafeNavigationController")

    static let transactionDetailsViewController = SceneType<SafeAppUI.TransactionDetailsViewController>(storyboard: Main.self, identifier: "TransactionDetailsViewController")

    static let transactionsTableViewController = SceneType<SafeAppUI.TransactionsTableViewController>(storyboard: Main.self, identifier: "TransactionsTableViewController")
  }
  enum MasterPassword: StoryboardType {
    static let storyboardName = "MasterPassword"

    static let startViewController = SceneType<SafeAppUI.StartViewController>(storyboard: MasterPassword.self, identifier: "StartViewController")

    static let termsAndConditionsViewController = SceneType<SafeAppUI.TermsAndConditionsViewController>(storyboard: MasterPassword.self, identifier: "TermsAndConditionsViewController")
  }
  enum NewSafe: StoryboardType {
    static let storyboardName = "NewSafe"

    static let confirmMnemonicViewController = SceneType<SafeAppUI.ConfirmMnemonicViewController>(storyboard: NewSafe.self, identifier: "ConfirmMnemonicViewController")

    static let guidelinesViewController = SceneType<SafeAppUI.GuidelinesViewController>(storyboard: NewSafe.self, identifier: "GuidelinesViewController")

    static let navigationController = SceneType<UINavigationController>(storyboard: NewSafe.self, identifier: "NavigationController")

    static let newSafeViewController = SceneType<SafeAppUI.NewSafeViewController>(storyboard: NewSafe.self, identifier: "NewSafeViewController")

    static let safeCreationViewController = SceneType<SafeAppUI.SafeCreationViewController>(storyboard: NewSafe.self, identifier: "SafeCreationViewController")

    static let saveMnemonicViewController = SceneType<SafeAppUI.SaveMnemonicViewController>(storyboard: NewSafe.self, identifier: "SaveMnemonicViewController")
  }
  enum PairWithBrowserExtension: StoryboardType {
    static let storyboardName = "PairWithBrowserExtension"

    static let pairWithBrowserExtensionViewController = SceneType<SafeAppUI.PairWithBrowserExtensionViewController>(storyboard: PairWithBrowserExtension.self, identifier: "PairWithBrowserExtensionViewController")
  }
  enum RecoverSafe: StoryboardType {
    static let storyboardName = "RecoverSafe"

    static let addressInputViewController = SceneType<SafeAppUI.AddressInputViewController>(storyboard: RecoverSafe.self, identifier: "AddressInputViewController")

    static let recoveryInProgressViewController = SceneType<SafeAppUI.RecoveryInProgressViewController>(storyboard: RecoverSafe.self, identifier: "RecoveryInProgressViewController")

    static let recoveryPhraseInputViewController = SceneType<SafeAppUI.RecoveryPhraseInputViewController>(storyboard: RecoverSafe.self, identifier: "RecoveryPhraseInputViewController")

    static let reviewRecoveryTransactionViewController = SceneType<SafeAppUI.ReviewRecoveryTransactionViewController>(storyboard: RecoverSafe.self, identifier: "ReviewRecoveryTransactionViewController")
  }
  enum SetupSafe: StoryboardType {
    static let storyboardName = "SetupSafe"

    static let setupSafeOptionsViewController = SceneType<SafeAppUI.SetupSafeOptionsViewController>(storyboard: SetupSafe.self, identifier: "SetupSafeOptionsViewController")
  }
  enum Unlock: StoryboardType {
    static let storyboardName = "Unlock"

    static let unlockViewController = SceneType<SafeAppUI.UnlockViewController>(storyboard: Unlock.self, identifier: "UnlockViewController")
  }
}

enum StoryboardSegue {
  enum Main: String, SegueType {
    case mainContentViewControllerSeague = "MainContentViewControllerSeague"
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

private final class BundleToken {}
