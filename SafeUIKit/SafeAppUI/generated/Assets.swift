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
  static let addTokenGetInTouch = ImageAsset(name: "add-token-get-in-touch")
  static let add = ImageAsset(name: "add")
  static let checkGreen = ImageAsset(name: "checkGreen")
  static let checkmark = ImageAsset(name: "checkmark")
  static let congratulations = ImageAsset(name: "congratulations")
  enum ContractUpgrade {
    static let contractUpgrade = ImageAsset(name: "contractUpgrade")
    static let upgrade1 = ImageAsset(name: "upgrade1")
    static let upgrade2 = ImageAsset(name: "upgrade2")
    static let upgrade3 = ImageAsset(name: "upgrade3")
  }
  enum CreateSafe {
    static let backupPhrase = ImageAsset(name: "backupPhrase")
    static let connectBrowserExtension = ImageAsset(name: "connectBrowserExtension")
    static let cryptoWithoutHassle = ImageAsset(name: "cryptoWithoutHassle")
    static let setup2FA = ImageAsset(name: "setup2FA")
    static let whatIsSafe = ImageAsset(name: "whatIsSafe")
    static let youAreInControl = ImageAsset(name: "youAreInControl")
  }
  static let dappPlaceholder = ImageAsset(name: "dapp-placeholder")
  static let errorIcon = ImageAsset(name: "error-icon")
  enum GetInTouch {
    static let gitter = ImageAsset(name: "gitter")
    static let mail = ImageAsset(name: "mail")
    static let telegram = ImageAsset(name: "telegram")
  }
  enum MainScreenHeader {
    static let arrows = ImageAsset(name: "arrows")
    static let coins = ImageAsset(name: "coins")
  }
  enum Manage2fa {
    static let _2FaDisable = ImageAsset(name: "2FaDisable")
    static let _2FaReplace = ImageAsset(name: "2FaReplace")
  }
  static let navbarFilled = ImageAsset(name: "navbar-filled")
  static let noResults = ImageAsset(name: "no-results")
  enum Onboarding {
    static let browserExtensionQr = ImageAsset(name: "browser-extension-qr")
    static let creatingSafe = ImageAsset(name: "creatingSafe")
    static let noSafes = ImageAsset(name: "no-safes")
    static let safeInprogress = ImageAsset(name: "safeInprogress")
  }
  static let qrIcon = ImageAsset(name: "qrIcon")
  enum ReplaceBrowserExtension {
    static let inProgressIcon = ImageAsset(name: "in-progress-icon")
    static let introIcon = ImageAsset(name: "intro-icon")
    static let scrollBottomGradient = ImageAsset(name: "scroll-bottom-gradient")
  }
  static let replacePhrase = ImageAsset(name: "replacePhrase")
  enum SafeCreationProgress {
    static let progressIndicator00000 = ImageAsset(name: "progress_indicator_00000")
    static let progressIndicator00001 = ImageAsset(name: "progress_indicator_00001")
    static let progressIndicator00002 = ImageAsset(name: "progress_indicator_00002")
    static let progressIndicator00003 = ImageAsset(name: "progress_indicator_00003")
    static let progressIndicator00004 = ImageAsset(name: "progress_indicator_00004")
    static let progressIndicator00005 = ImageAsset(name: "progress_indicator_00005")
    static let progressIndicator00006 = ImageAsset(name: "progress_indicator_00006")
    static let progressIndicator00007 = ImageAsset(name: "progress_indicator_00007")
    static let progressIndicator00008 = ImageAsset(name: "progress_indicator_00008")
    static let progressIndicator00009 = ImageAsset(name: "progress_indicator_00009")
    static let progressIndicator00010 = ImageAsset(name: "progress_indicator_00010")
    static let progressIndicator00011 = ImageAsset(name: "progress_indicator_00011")
    static let progressIndicator00012 = ImageAsset(name: "progress_indicator_00012")
    static let progressIndicator00013 = ImageAsset(name: "progress_indicator_00013")
    static let progressIndicator00014 = ImageAsset(name: "progress_indicator_00014")
    static let progressIndicator00015 = ImageAsset(name: "progress_indicator_00015")
    static let progressIndicator00016 = ImageAsset(name: "progress_indicator_00016")
    static let progressIndicator00017 = ImageAsset(name: "progress_indicator_00017")
    static let progressIndicator00018 = ImageAsset(name: "progress_indicator_00018")
    static let progressIndicator00019 = ImageAsset(name: "progress_indicator_00019")
    static let progressIndicator00020 = ImageAsset(name: "progress_indicator_00020")
    static let progressIndicator00021 = ImageAsset(name: "progress_indicator_00021")
    static let progressIndicator00022 = ImageAsset(name: "progress_indicator_00022")
    static let progressIndicator00023 = ImageAsset(name: "progress_indicator_00023")
    static let progressIndicator00024 = ImageAsset(name: "progress_indicator_00024")
    static let progressIndicator00025 = ImageAsset(name: "progress_indicator_00025")
    static let progressIndicator00026 = ImageAsset(name: "progress_indicator_00026")
    static let progressIndicator00027 = ImageAsset(name: "progress_indicator_00027")
    static let progressIndicator00028 = ImageAsset(name: "progress_indicator_00028")
    static let progressIndicator00029 = ImageAsset(name: "progress_indicator_00029")
    static let progressIndicator00030 = ImageAsset(name: "progress_indicator_00030")
    static let progressIndicator00031 = ImageAsset(name: "progress_indicator_00031")
    static let progressIndicator00032 = ImageAsset(name: "progress_indicator_00032")
    static let progressIndicator00033 = ImageAsset(name: "progress_indicator_00033")
    static let progressIndicator00034 = ImageAsset(name: "progress_indicator_00034")
    static let progressIndicator00035 = ImageAsset(name: "progress_indicator_00035")
    static let progressIndicator00036 = ImageAsset(name: "progress_indicator_00036")
    static let progressIndicator00037 = ImageAsset(name: "progress_indicator_00037")
    static let progressIndicator00038 = ImageAsset(name: "progress_indicator_00038")
    static let progressIndicator00039 = ImageAsset(name: "progress_indicator_00039")
    static let progressIndicator00040 = ImageAsset(name: "progress_indicator_00040")
    static let progressIndicator00041 = ImageAsset(name: "progress_indicator_00041")
    static let progressIndicator00042 = ImageAsset(name: "progress_indicator_00042")
    static let progressIndicator00043 = ImageAsset(name: "progress_indicator_00043")
    static let progressIndicator00044 = ImageAsset(name: "progress_indicator_00044")
    static let progressIndicator00045 = ImageAsset(name: "progress_indicator_00045")
    static let progressIndicator00046 = ImageAsset(name: "progress_indicator_00046")
  }
  enum SegmentBar {
    static let `left` = ImageAsset(name: "left")
    static let middle = ImageAsset(name: "middle")
    static let `right` = ImageAsset(name: "right")
  }
  enum Select2fa {
    static let authenticatorSmall = ImageAsset(name: "authenticatorSmall")
    static let statusKeycard = ImageAsset(name: "statusKeycard")
  }
  static let shadow = ImageAsset(name: "shadow")
  static let shareIcon = ImageAsset(name: "share-icon")
  static let statusKeycardActivated = ImageAsset(name: "statusKeycardActivated")
  static let statusKeycardIntro = ImageAsset(name: "statusKeycardIntro")
  static let statusKeycardPaired = ImageAsset(name: "statusKeycardPaired")
  enum TokenIcons {
    static let eth = ImageAsset(name: "ETH")
    static let defaultToken = ImageAsset(name: "default-token")
  }
  enum TransactionDetails {
    static let arrowTransaction = ImageAsset(name: "arrow_transaction")
    static let externalLink = ImageAsset(name: "external_link")
  }
  enum TransactionOverviewIcons {
    static let error = ImageAsset(name: "error")
    static let iconIncoming = ImageAsset(name: "icon-incoming")
    static let iconOutgoing = ImageAsset(name: "icon-outgoing")
    static let iconSettings = ImageAsset(name: "icon-settings")
  }
  static let transparentBackground = ImageAsset(name: "transparent_background")
  enum UnlockScreen {
    static let faceIdIcon = ImageAsset(name: "face-id-icon")
    static let safeHeaderLogoRinkeby = ImageAsset(name: "safe-header-logo-rinkeby")
    static let safeHeaderLogo = ImageAsset(name: "safe-header-logo")
    static let touchIdIcon = ImageAsset(name: "touch-id-icon")
  }
  enum WalletConnect {
    static let _1 = ImageAsset(name: "1")
    static let _2 = ImageAsset(name: "2")
    static let _3 = ImageAsset(name: "3")
  }

  // swiftlint:disable trailing_comma
  static let allColors: [ColorAsset] = [
  ]
  static let allImages: [ImageAsset] = [
    chevronHighlighted,
    chevron,
    addTokenGetInTouch,
    add,
    checkGreen,
    checkmark,
    congratulations,
    ContractUpgrade.contractUpgrade,
    ContractUpgrade.upgrade1,
    ContractUpgrade.upgrade2,
    ContractUpgrade.upgrade3,
    CreateSafe.backupPhrase,
    CreateSafe.connectBrowserExtension,
    CreateSafe.cryptoWithoutHassle,
    CreateSafe.setup2FA,
    CreateSafe.whatIsSafe,
    CreateSafe.youAreInControl,
    dappPlaceholder,
    errorIcon,
    GetInTouch.gitter,
    GetInTouch.mail,
    GetInTouch.telegram,
    MainScreenHeader.arrows,
    MainScreenHeader.coins,
    Manage2fa._2FaDisable,
    Manage2fa._2FaReplace,
    navbarFilled,
    noResults,
    Onboarding.browserExtensionQr,
    Onboarding.creatingSafe,
    Onboarding.noSafes,
    Onboarding.safeInprogress,
    qrIcon,
    ReplaceBrowserExtension.inProgressIcon,
    ReplaceBrowserExtension.introIcon,
    ReplaceBrowserExtension.scrollBottomGradient,
    replacePhrase,
    SafeCreationProgress.progressIndicator00000,
    SafeCreationProgress.progressIndicator00001,
    SafeCreationProgress.progressIndicator00002,
    SafeCreationProgress.progressIndicator00003,
    SafeCreationProgress.progressIndicator00004,
    SafeCreationProgress.progressIndicator00005,
    SafeCreationProgress.progressIndicator00006,
    SafeCreationProgress.progressIndicator00007,
    SafeCreationProgress.progressIndicator00008,
    SafeCreationProgress.progressIndicator00009,
    SafeCreationProgress.progressIndicator00010,
    SafeCreationProgress.progressIndicator00011,
    SafeCreationProgress.progressIndicator00012,
    SafeCreationProgress.progressIndicator00013,
    SafeCreationProgress.progressIndicator00014,
    SafeCreationProgress.progressIndicator00015,
    SafeCreationProgress.progressIndicator00016,
    SafeCreationProgress.progressIndicator00017,
    SafeCreationProgress.progressIndicator00018,
    SafeCreationProgress.progressIndicator00019,
    SafeCreationProgress.progressIndicator00020,
    SafeCreationProgress.progressIndicator00021,
    SafeCreationProgress.progressIndicator00022,
    SafeCreationProgress.progressIndicator00023,
    SafeCreationProgress.progressIndicator00024,
    SafeCreationProgress.progressIndicator00025,
    SafeCreationProgress.progressIndicator00026,
    SafeCreationProgress.progressIndicator00027,
    SafeCreationProgress.progressIndicator00028,
    SafeCreationProgress.progressIndicator00029,
    SafeCreationProgress.progressIndicator00030,
    SafeCreationProgress.progressIndicator00031,
    SafeCreationProgress.progressIndicator00032,
    SafeCreationProgress.progressIndicator00033,
    SafeCreationProgress.progressIndicator00034,
    SafeCreationProgress.progressIndicator00035,
    SafeCreationProgress.progressIndicator00036,
    SafeCreationProgress.progressIndicator00037,
    SafeCreationProgress.progressIndicator00038,
    SafeCreationProgress.progressIndicator00039,
    SafeCreationProgress.progressIndicator00040,
    SafeCreationProgress.progressIndicator00041,
    SafeCreationProgress.progressIndicator00042,
    SafeCreationProgress.progressIndicator00043,
    SafeCreationProgress.progressIndicator00044,
    SafeCreationProgress.progressIndicator00045,
    SafeCreationProgress.progressIndicator00046,
    SegmentBar.`left`,
    SegmentBar.middle,
    SegmentBar.`right`,
    Select2fa.authenticatorSmall,
    Select2fa.statusKeycard,
    shadow,
    shareIcon,
    statusKeycardActivated,
    statusKeycardIntro,
    statusKeycardPaired,
    TokenIcons.eth,
    TokenIcons.defaultToken,
    TransactionDetails.arrowTransaction,
    TransactionDetails.externalLink,
    TransactionOverviewIcons.error,
    TransactionOverviewIcons.iconIncoming,
    TransactionOverviewIcons.iconOutgoing,
    TransactionOverviewIcons.iconSettings,
    transparentBackground,
    UnlockScreen.faceIdIcon,
    UnlockScreen.safeHeaderLogoRinkeby,
    UnlockScreen.safeHeaderLogo,
    UnlockScreen.touchIdIcon,
    WalletConnect._1,
    WalletConnect._2,
    WalletConnect._3,
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
