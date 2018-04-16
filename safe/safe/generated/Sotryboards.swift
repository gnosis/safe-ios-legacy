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

    static let unlockViewController = SceneType<safe.UnlockViewController>(storyboard: AppFlow.self, identifier: "UnlockViewController")
  }
  enum LaunchScreen: StoryboardType {
    static let storyboardName = "LaunchScreen"

    static let initialScene = InitialSceneType<UIViewController>(storyboard: LaunchScreen.self)
  }
  enum MasterPassword: StoryboardType {
    static let storyboardName = "MasterPassword"

    static let confirmPaswordViewController = SceneType<safe.ConfirmPaswordViewController>(storyboard: MasterPassword.self, identifier: "ConfirmPaswordViewController")

    static let setPasswordViewController = SceneType<safe.SetPasswordViewController>(storyboard: MasterPassword.self, identifier: "SetPasswordViewController")

    static let startViewController = SceneType<safe.StartViewController>(storyboard: MasterPassword.self, identifier: "StartViewController")
  }
  enum SetupRecovery: StoryboardType {
    static let storyboardName = "SetupRecovery"

    static let confirmMnemonicViewController = SceneType<safe.ConfirmMnemonicViewController>(storyboard: SetupRecovery.self, identifier: "ConfirmMnemonicViewController")

    static let navigationController = SceneType<UINavigationController>(storyboard: SetupRecovery.self, identifier: "NavigationController")

    static let saveMnemonicViewController = SceneType<safe.SaveMnemonicViewController>(storyboard: SetupRecovery.self, identifier: "SaveMnemonicViewController")

    static let selectRecoveryOptionViewController = SceneType<safe.RecoveryOptionsViewController>(storyboard: SetupRecovery.self, identifier: "SelectRecoveryOptionViewController")
  }
  enum SetupSafe: StoryboardType {
    static let storyboardName = "SetupSafe"

    static let setupSafeOptionsViewController = SceneType<safe.SetupSafeOptionsViewController>(storyboard: SetupSafe.self, identifier: "SetupSafeOptionsViewController")
  }
}

enum StoryboardSegue {
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

private final class BundleToken {}
