// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSImage
  typealias AssetColorTypeAlias = NSColor
  typealias Image = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIImage
  typealias AssetColorTypeAlias = UIColor
  typealias Image = UIImage
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

@available(*, deprecated, renamed: "ImageAsset")
typealias AssetType = ImageAsset

struct ImageAsset {
  fileprivate var name: String

  var image: Image {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else { fatalError("Unable to load image named \(name).") }
    return result
  }
}

struct ColorAsset {
  fileprivate var name: String

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  var color: AssetColorTypeAlias {
    return AssetColorTypeAlias(asset: self)
  }
}

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
enum Asset {
  static let chevronHighlighted = ImageAsset(name: "Chevron-highlighted")
  static let chevron = ImageAsset(name: "Chevron")
  static let add = ImageAsset(name: "add")
  static let checkmark = ImageAsset(name: "checkmark")
  static let congratulations = ImageAsset(name: "congratulations")
  enum ConnectBrowserExtension {
    static let connectIntroIcon = ImageAsset(name: "connect-intro-icon")
  }
  enum MainScreenHeader {
    static let arrows = ImageAsset(name: "arrows")
    static let coins = ImageAsset(name: "coins")
  }
  enum Onboarding {
    static let browserExtensionQr = ImageAsset(name: "browser-extension-qr")
    static let creatingSafe = ImageAsset(name: "creatingSafe")
    static let errorIcon = ImageAsset(name: "error-icon")
    static let ironSafe = ImageAsset(name: "iron-safe")
    static let noSafes = ImageAsset(name: "no-safes")
    static let safeInprogress = ImageAsset(name: "safeInprogress")
    static let water = ImageAsset(name: "water")
  }
  static let qrIcon = ImageAsset(name: "qrIcon")
  enum ReplaceBrowserExtension {
    static let estimationErrorIcon = ImageAsset(name: "estimation-error-icon")
    static let introIcon = ImageAsset(name: "intro-icon")
    static let scrollBottomGradient = ImageAsset(name: "scroll-bottom-gradient")
  }
  static let replacePhrase = ImageAsset(name: "replacePhrase")
  static let shadow = ImageAsset(name: "shadow")
  static let shareIcon = ImageAsset(name: "share-icon")
  enum TermsScreen {
    static let squareButtonBorder = ImageAsset(name: "square-button-border")
  }
  enum TokenIcons {
    static let eth = ImageAsset(name: "ETH")
    static let defaultToken = ImageAsset(name: "default-token")
  }
  enum TransactionDetails {
    static let arrowTransaction = ImageAsset(name: "arrow_transaction")
    static let externalLink = ImageAsset(name: "external_link")
  }
  enum TransactionEdit {
    static let scanQrCopy = ImageAsset(name: "scan_qr_copy")
    static let shape = ImageAsset(name: "shape")
    static let `switch` = ImageAsset(name: "switch")
  }
  enum TransactionOverviewIcons {
    static let error = ImageAsset(name: "error")
    static let iconIncoming = ImageAsset(name: "icon-incoming")
    static let iconOutgoing = ImageAsset(name: "icon-outgoing")
    static let iconSettings = ImageAsset(name: "icon-settings")
    static let settingTransaction = ImageAsset(name: "setting_transaction")
  }
  static let transparentBackground = ImageAsset(name: "transparent_background")
  enum UnlockScreen {
    static let faceIdIcon = ImageAsset(name: "face-id-icon")
    static let safeHeaderLogo = ImageAsset(name: "safe-header-logo")
    static let touchIdIcon = ImageAsset(name: "touch-id-icon")
  }

  // swiftlint:disable trailing_comma
  static let allColors: [ColorAsset] = [
  ]
  static let allImages: [ImageAsset] = [
    chevronHighlighted,
    chevron,
    add,
    checkmark,
    congratulations,
    ConnectBrowserExtension.connectIntroIcon,
    MainScreenHeader.arrows,
    MainScreenHeader.coins,
    Onboarding.browserExtensionQr,
    Onboarding.creatingSafe,
    Onboarding.errorIcon,
    Onboarding.ironSafe,
    Onboarding.noSafes,
    Onboarding.safeInprogress,
    Onboarding.water,
    qrIcon,
    ReplaceBrowserExtension.estimationErrorIcon,
    ReplaceBrowserExtension.introIcon,
    ReplaceBrowserExtension.scrollBottomGradient,
    replacePhrase,
    shadow,
    shareIcon,
    TermsScreen.squareButtonBorder,
    TokenIcons.eth,
    TokenIcons.defaultToken,
    TransactionDetails.arrowTransaction,
    TransactionDetails.externalLink,
    TransactionEdit.scanQrCopy,
    TransactionEdit.shape,
    TransactionEdit.`switch`,
    TransactionOverviewIcons.error,
    TransactionOverviewIcons.iconIncoming,
    TransactionOverviewIcons.iconOutgoing,
    TransactionOverviewIcons.iconSettings,
    TransactionOverviewIcons.settingTransaction,
    transparentBackground,
    UnlockScreen.faceIdIcon,
    UnlockScreen.safeHeaderLogo,
    UnlockScreen.touchIdIcon,
  ]
  // swiftlint:enable trailing_comma
  @available(*, deprecated, renamed: "allImages")
  static let allValues: [AssetType] = allImages
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

extension Image {
  @available(iOS 1.0, tvOS 1.0, watchOS 1.0, *)
  @available(OSX, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = Bundle(for: BundleToken.self)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

extension AssetColorTypeAlias {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  convenience init!(asset: ColorAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

private final class BundleToken {}
