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
  enum AddressInput {
    static let dots = ImageAsset(name: "dots")
  }
  static let backgroundDarkImage = ImageAsset(name: "background-dark-image")
  enum BorderedButton {
    static let borderedInactive = ImageAsset(name: "Bordered_Inactive")
    static let borderedNormal = ImageAsset(name: "Bordered_Normal")
    static let borderedPressed = ImageAsset(name: "Bordered_Pressed")
  }
  static let closeIcon = ImageAsset(name: "close-icon")
  enum Confirmation {
    static let confirmed = ImageAsset(name: "Confirmed")
    static let rejected = ImageAsset(name: "Rejected")
  }
  static let error = ImageAsset(name: "error")
  enum FilledButton {
    static let filledInactive = ImageAsset(name: "Filled_Inactive")
    static let filledNormal = ImageAsset(name: "Filled_Normal")
    static let filledPressed = ImageAsset(name: "Filled_Pressed")
  }
  static let qrCode = ImageAsset(name: "qr-code")
  static let settings = ImageAsset(name: "settings")
  static let shareLink = ImageAsset(name: "share-link")
  enum TextInputs {
    static let clearIcon = ImageAsset(name: "clear-icon")
    static let defaultIcon = ImageAsset(name: "default-icon")
    static let errorIcon = ImageAsset(name: "error-icon")
    static let successIcon = ImageAsset(name: "success-icon")
  }
  enum ThreeSteps {
    static let _2InCircleActive = ImageAsset(name: "2_in_circle_active")
    static let _2InCircleInactive = ImageAsset(name: "2_in_circle_inactive")
    static let _2Skipped = ImageAsset(name: "2_skipped")
    static let _3InCircleActive = ImageAsset(name: "3_in_circle_active")
    static let _3InCircleInactive = ImageAsset(name: "3_in_circle_inactive")
    static let checkmarkInCircle = ImageAsset(name: "checkmark_in_circle")
    static let filledLineGreen = ImageAsset(name: "filled_line_green")
    static let filledLineGrey = ImageAsset(name: "filled_line_grey")
    static let gradientLine = ImageAsset(name: "gradient_line")
    static let gradientLineSkipped = ImageAsset(name: "gradient_line_skipped")
  }
  enum TokenIcons {
    static let eth = ImageAsset(name: "ETH")
    static let defaultToken = ImageAsset(name: "default-token")
  }
  enum TransferView {
    static let arrowDown = ImageAsset(name: "arrow-down")
  }
  enum Twofa {
    static let _2faRequired00000 = ImageAsset(name: "2fa_required_00000")
    static let _2faRequired00001 = ImageAsset(name: "2fa_required_00001")
    static let _2faRequired00002 = ImageAsset(name: "2fa_required_00002")
    static let _2faRequired00003 = ImageAsset(name: "2fa_required_00003")
    static let _2faRequired00004 = ImageAsset(name: "2fa_required_00004")
    static let _2faRequired00005 = ImageAsset(name: "2fa_required_00005")
    static let _2faRequired00006 = ImageAsset(name: "2fa_required_00006")
    static let _2faRequired00007 = ImageAsset(name: "2fa_required_00007")
    static let _2faRequired00008 = ImageAsset(name: "2fa_required_00008")
    static let _2faRequired00009 = ImageAsset(name: "2fa_required_00009")
    static let _2faRequired00010 = ImageAsset(name: "2fa_required_00010")
    static let _2faRequired00011 = ImageAsset(name: "2fa_required_00011")
    static let _2faRequired00012 = ImageAsset(name: "2fa_required_00012")
    static let _2faRequired00013 = ImageAsset(name: "2fa_required_00013")
    static let _2faRequired00014 = ImageAsset(name: "2fa_required_00014")
    static let _2faRequired00015 = ImageAsset(name: "2fa_required_00015")
    static let _2faRequired00016 = ImageAsset(name: "2fa_required_00016")
    static let _2faRequired00017 = ImageAsset(name: "2fa_required_00017")
    static let _2faRequired00018 = ImageAsset(name: "2fa_required_00018")
    static let _2faRequired00019 = ImageAsset(name: "2fa_required_00019")
    static let _2faRequired00020 = ImageAsset(name: "2fa_required_00020")
    static let _2faRequired00021 = ImageAsset(name: "2fa_required_00021")
    static let _2faRequired00022 = ImageAsset(name: "2fa_required_00022")
    static let _2faRequired00023 = ImageAsset(name: "2fa_required_00023")
    static let _2faRequired00024 = ImageAsset(name: "2fa_required_00024")
    static let _2faRequired00025 = ImageAsset(name: "2fa_required_00025")
    static let _2faRequired00026 = ImageAsset(name: "2fa_required_00026")
    static let _2faRequired00027 = ImageAsset(name: "2fa_required_00027")
    static let _2faRequired00028 = ImageAsset(name: "2fa_required_00028")
    static let _2faRequired00029 = ImageAsset(name: "2fa_required_00029")
    static let _2faRequired00030 = ImageAsset(name: "2fa_required_00030")
    static let _2faRequired00031 = ImageAsset(name: "2fa_required_00031")
    static let _2faRequired00032 = ImageAsset(name: "2fa_required_00032")
    static let _2faRequired00033 = ImageAsset(name: "2fa_required_00033")
    static let _2faRequired00034 = ImageAsset(name: "2fa_required_00034")
    static let _2faRequired00035 = ImageAsset(name: "2fa_required_00035")
    static let _2faRequired00036 = ImageAsset(name: "2fa_required_00036")
    static let _2faRequired00037 = ImageAsset(name: "2fa_required_00037")
    static let _2faRequired00038 = ImageAsset(name: "2fa_required_00038")
    static let _2faRequired00039 = ImageAsset(name: "2fa_required_00039")
    static let _2faRequired00040 = ImageAsset(name: "2fa_required_00040")
  }

  // swiftlint:disable trailing_comma
  static let allColors: [ColorAsset] = [
  ]
  static let allImages: [ImageAsset] = [
    AddressInput.dots,
    backgroundDarkImage,
    BorderedButton.borderedInactive,
    BorderedButton.borderedNormal,
    BorderedButton.borderedPressed,
    closeIcon,
    Confirmation.confirmed,
    Confirmation.rejected,
    error,
    FilledButton.filledInactive,
    FilledButton.filledNormal,
    FilledButton.filledPressed,
    qrCode,
    settings,
    shareLink,
    TextInputs.clearIcon,
    TextInputs.defaultIcon,
    TextInputs.errorIcon,
    TextInputs.successIcon,
    ThreeSteps._2InCircleActive,
    ThreeSteps._2InCircleInactive,
    ThreeSteps._2Skipped,
    ThreeSteps._3InCircleActive,
    ThreeSteps._3InCircleInactive,
    ThreeSteps.checkmarkInCircle,
    ThreeSteps.filledLineGreen,
    ThreeSteps.filledLineGrey,
    ThreeSteps.gradientLine,
    ThreeSteps.gradientLineSkipped,
    TokenIcons.eth,
    TokenIcons.defaultToken,
    TransferView.arrowDown,
    Twofa._2faRequired00000,
    Twofa._2faRequired00001,
    Twofa._2faRequired00002,
    Twofa._2faRequired00003,
    Twofa._2faRequired00004,
    Twofa._2faRequired00005,
    Twofa._2faRequired00006,
    Twofa._2faRequired00007,
    Twofa._2faRequired00008,
    Twofa._2faRequired00009,
    Twofa._2faRequired00010,
    Twofa._2faRequired00011,
    Twofa._2faRequired00012,
    Twofa._2faRequired00013,
    Twofa._2faRequired00014,
    Twofa._2faRequired00015,
    Twofa._2faRequired00016,
    Twofa._2faRequired00017,
    Twofa._2faRequired00018,
    Twofa._2faRequired00019,
    Twofa._2faRequired00020,
    Twofa._2faRequired00021,
    Twofa._2faRequired00022,
    Twofa._2faRequired00023,
    Twofa._2faRequired00024,
    Twofa._2faRequired00025,
    Twofa._2faRequired00026,
    Twofa._2faRequired00027,
    Twofa._2faRequired00028,
    Twofa._2faRequired00029,
    Twofa._2faRequired00030,
    Twofa._2faRequired00031,
    Twofa._2faRequired00032,
    Twofa._2faRequired00033,
    Twofa._2faRequired00034,
    Twofa._2faRequired00035,
    Twofa._2faRequired00036,
    Twofa._2faRequired00037,
    Twofa._2faRequired00038,
    Twofa._2faRequired00039,
    Twofa._2faRequired00040,
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
