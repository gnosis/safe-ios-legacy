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
  enum MasterPassword: StoryboardType {
    static let storyboardName = "MasterPassword"

    static let confirmPaswordViewController = SceneType<SafeAppUI.ConfirmPaswordViewController>(storyboard: MasterPassword.self, identifier: "ConfirmPaswordViewController")

    static let setPasswordViewController = SceneType<SafeAppUI.SetPasswordViewController>(storyboard: MasterPassword.self, identifier: "SetPasswordViewController")

    static let startViewController = SceneType<SafeAppUI.StartViewController>(storyboard: MasterPassword.self, identifier: "StartViewController")
  }
  enum NewSafe: StoryboardType {
    static let storyboardName = "NewSafe"

    static let confirmMnemonicViewController = SceneType<SafeAppUI.ConfirmMnemonicViewController>(storyboard: NewSafe.self, identifier: "ConfirmMnemonicViewController")

    static let navigationController = SceneType<UINavigationController>(storyboard: NewSafe.self, identifier: "NavigationController")

    static let newSafeViewController = SceneType<SafeAppUI.NewSafeViewController>(storyboard: NewSafe.self, identifier: "NewSafeViewController")

    static let pairWithBrowserExtensionViewController = SceneType<SafeAppUI.PairWithBrowserExtensionViewController>(storyboard: NewSafe.self, identifier: "PairWithBrowserExtensionViewController")

    static let saveMnemonicViewController = SceneType<SafeAppUI.SaveMnemonicViewController>(storyboard: NewSafe.self, identifier: "SaveMnemonicViewController")
  }
  enum SetupSafe: StoryboardType {
    static let storyboardName = "SetupSafe"

    static let setupSafeOptionsViewController = SceneType<SafeAppUI.SetupSafeOptionsViewController>(storyboard: SetupSafe.self, identifier: "SetupSafeOptionsViewController")
  }
}

enum StoryboardSegue {
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

private final class BundleToken {}
