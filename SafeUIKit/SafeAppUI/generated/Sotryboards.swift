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
  enum AppFlow: StoryboardType {
    static let storyboardName = "AppFlow"

    static let unlockViewController = SceneType<SafeAppUI.UnlockViewController>(storyboard: AppFlow.self, identifier: "UnlockViewController")
  }
  enum Main: StoryboardType {
    static let storyboardName = "Main"

    static let addTokenNavigationController = SceneType<UINavigationController>(storyboard: Main.self, identifier: "AddTokenNavigationController")

    static let addTokenTableViewController = SceneType<SafeAppUI.AddTokenTableViewController>(storyboard: Main.self, identifier: "AddTokenTableViewController")

    static let fundsTransferTransactionViewController = SceneType<SafeAppUI.FundsTransferTransactionViewController>(storyboard: Main.self, identifier: "FundsTransferTransactionViewController")

    static let mainViewController = SceneType<SafeAppUI.MainViewController>(storyboard: Main.self, identifier: "MainViewController")

    static let menuTableViewController = SceneType<SafeAppUI.MenuTableViewController>(storyboard: Main.self, identifier: "MenuTableViewController")

    static let safeAddressViewController = SceneType<SafeAppUI.SafeAddressViewController>(storyboard: Main.self, identifier: "SafeAddressViewController")

    static let safeNavigationController = SceneType<SafeAppUI.SafeNavigationController>(storyboard: Main.self, identifier: "SafeNavigationController")

    static let transactionDetailsViewController = SceneType<SafeAppUI.TransactionDetailsViewController>(storyboard: Main.self, identifier: "TransactionDetailsViewController")

    static let transactionReviewViewController = SceneType<SafeAppUI.TransactionReviewViewController>(storyboard: Main.self, identifier: "TransactionReviewViewController")

    static let transactionsTableViewController = SceneType<SafeAppUI.TransactionsTableViewController>(storyboard: Main.self, identifier: "TransactionsTableViewController")
  }
  enum MasterPassword: StoryboardType {
    static let storyboardName = "MasterPassword"

    static let passwordViewController = SceneType<SafeAppUI.PasswordViewController>(storyboard: MasterPassword.self, identifier: "PasswordViewController")

    static let startViewController = SceneType<SafeAppUI.StartViewController>(storyboard: MasterPassword.self, identifier: "StartViewController")
  }
  enum NewSafe: StoryboardType {
    static let storyboardName = "NewSafe"

    static let confirmMnemonicViewController = SceneType<SafeAppUI.ConfirmMnemonicViewController>(storyboard: NewSafe.self, identifier: "ConfirmMnemonicViewController")

    static let navigationController = SceneType<UINavigationController>(storyboard: NewSafe.self, identifier: "NavigationController")

    static let newSafeViewController = SceneType<SafeAppUI.NewSafeViewController>(storyboard: NewSafe.self, identifier: "NewSafeViewController")

    static let pairWithBrowserExtensionViewController = SceneType<SafeAppUI.PairWithBrowserExtensionViewController>(storyboard: NewSafe.self, identifier: "PairWithBrowserExtensionViewController")

    static let pendingSafeViewController = SceneType<SafeAppUI.PendingSafeViewController>(storyboard: NewSafe.self, identifier: "PendingSafeViewController")

    static let saveMnemonicViewController = SceneType<SafeAppUI.SaveMnemonicViewController>(storyboard: NewSafe.self, identifier: "SaveMnemonicViewController")
  }
  enum SetupSafe: StoryboardType {
    static let storyboardName = "SetupSafe"

    static let setupSafeOptionsViewController = SceneType<SafeAppUI.SetupSafeOptionsViewController>(storyboard: SetupSafe.self, identifier: "SetupSafeOptionsViewController")
  }
}

enum StoryboardSegue {
  enum Main: String, SegueType {
    case mainContentViewControllerSeague = "MainContentViewControllerSeague"
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

private final class BundleToken {}
