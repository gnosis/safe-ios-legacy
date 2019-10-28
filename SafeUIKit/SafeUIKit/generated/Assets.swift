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
  enum Keycard {
    static let keycardRequired00000 = ImageAsset(name: "keycard_required_00000")
    static let keycardRequired00001 = ImageAsset(name: "keycard_required_00001")
    static let keycardRequired00002 = ImageAsset(name: "keycard_required_00002")
    static let keycardRequired00003 = ImageAsset(name: "keycard_required_00003")
    static let keycardRequired00004 = ImageAsset(name: "keycard_required_00004")
    static let keycardRequired00005 = ImageAsset(name: "keycard_required_00005")
    static let keycardRequired00006 = ImageAsset(name: "keycard_required_00006")
    static let keycardRequired00007 = ImageAsset(name: "keycard_required_00007")
    static let keycardRequired00008 = ImageAsset(name: "keycard_required_00008")
    static let keycardRequired00009 = ImageAsset(name: "keycard_required_00009")
    static let keycardRequired00010 = ImageAsset(name: "keycard_required_00010")
    static let keycardRequired00011 = ImageAsset(name: "keycard_required_00011")
    static let keycardRequired00012 = ImageAsset(name: "keycard_required_00012")
    static let keycardRequired00013 = ImageAsset(name: "keycard_required_00013")
    static let keycardRequired00014 = ImageAsset(name: "keycard_required_00014")
    static let keycardRequired00015 = ImageAsset(name: "keycard_required_00015")
    static let keycardRequired00016 = ImageAsset(name: "keycard_required_00016")
    static let keycardRequired00017 = ImageAsset(name: "keycard_required_00017")
    static let keycardRequired00018 = ImageAsset(name: "keycard_required_00018")
    static let keycardRequired00019 = ImageAsset(name: "keycard_required_00019")
    static let keycardRequired00020 = ImageAsset(name: "keycard_required_00020")
    static let keycardRequired00021 = ImageAsset(name: "keycard_required_00021")
    static let keycardRequired00022 = ImageAsset(name: "keycard_required_00022")
    static let keycardRequired00023 = ImageAsset(name: "keycard_required_00023")
    static let keycardRequired00024 = ImageAsset(name: "keycard_required_00024")
    static let keycardRequired00025 = ImageAsset(name: "keycard_required_00025")
    static let keycardRequired00026 = ImageAsset(name: "keycard_required_00026")
    static let keycardRequired00027 = ImageAsset(name: "keycard_required_00027")
    static let keycardRequired00028 = ImageAsset(name: "keycard_required_00028")
    static let keycardRequired00029 = ImageAsset(name: "keycard_required_00029")
    static let keycardRequired00030 = ImageAsset(name: "keycard_required_00030")
    static let keycardRequired00031 = ImageAsset(name: "keycard_required_00031")
    static let keycardRequired00032 = ImageAsset(name: "keycard_required_00032")
    static let keycardRequired00033 = ImageAsset(name: "keycard_required_00033")
    static let keycardRequired00034 = ImageAsset(name: "keycard_required_00034")
    static let keycardRequired00035 = ImageAsset(name: "keycard_required_00035")
    static let keycardRequired00036 = ImageAsset(name: "keycard_required_00036")
    static let keycardRequired00037 = ImageAsset(name: "keycard_required_00037")
    static let keycardRequired00038 = ImageAsset(name: "keycard_required_00038")
    static let keycardRequired00039 = ImageAsset(name: "keycard_required_00039")
    static let keycardRequired00040 = ImageAsset(name: "keycard_required_00040")
    static let keycardRequired00041 = ImageAsset(name: "keycard_required_00041")
    static let keycardRequired00042 = ImageAsset(name: "keycard_required_00042")
    static let keycardRequired00043 = ImageAsset(name: "keycard_required_00043")
    static let keycardRequired00044 = ImageAsset(name: "keycard_required_00044")
    static let keycardRequired00045 = ImageAsset(name: "keycard_required_00045")
    static let keycardRequired00046 = ImageAsset(name: "keycard_required_00046")
    static let keycardRequired00047 = ImageAsset(name: "keycard_required_00047")
    static let keycardRequired00048 = ImageAsset(name: "keycard_required_00048")
    static let keycardRequired00049 = ImageAsset(name: "keycard_required_00049")
    static let keycardRequired00050 = ImageAsset(name: "keycard_required_00050")
    static let keycardRequired00051 = ImageAsset(name: "keycard_required_00051")
    static let keycardRequired00052 = ImageAsset(name: "keycard_required_00052")
    static let keycardRequired00053 = ImageAsset(name: "keycard_required_00053")
    static let keycardRequired00054 = ImageAsset(name: "keycard_required_00054")
    static let keycardRequired00055 = ImageAsset(name: "keycard_required_00055")
    static let keycardRequired00056 = ImageAsset(name: "keycard_required_00056")
    static let keycardRequired00057 = ImageAsset(name: "keycard_required_00057")
    static let keycardRequired00058 = ImageAsset(name: "keycard_required_00058")
    static let keycardRequired00059 = ImageAsset(name: "keycard_required_00059")
    static let keycardRequired00060 = ImageAsset(name: "keycard_required_00060")
    static let keycardRequired00061 = ImageAsset(name: "keycard_required_00061")
    static let keycardRequired00062 = ImageAsset(name: "keycard_required_00062")
    static let keycardRequired00063 = ImageAsset(name: "keycard_required_00063")
    static let keycardRequired00064 = ImageAsset(name: "keycard_required_00064")
    static let keycardRequired00065 = ImageAsset(name: "keycard_required_00065")
    static let keycardRequired00066 = ImageAsset(name: "keycard_required_00066")
    static let keycardRequired00067 = ImageAsset(name: "keycard_required_00067")
    static let keycardRequired00068 = ImageAsset(name: "keycard_required_00068")
    static let keycardRequired00069 = ImageAsset(name: "keycard_required_00069")
    static let keycardRequired00070 = ImageAsset(name: "keycard_required_00070")
    static let keycardRequired00071 = ImageAsset(name: "keycard_required_00071")
    static let keycardRequired00072 = ImageAsset(name: "keycard_required_00072")
    static let keycardRequired00073 = ImageAsset(name: "keycard_required_00073")
    static let keycardRequired00074 = ImageAsset(name: "keycard_required_00074")
    static let keycardRequired00075 = ImageAsset(name: "keycard_required_00075")
    static let keycardRequired00076 = ImageAsset(name: "keycard_required_00076")
    static let keycardRequired00077 = ImageAsset(name: "keycard_required_00077")
    static let keycardRequired00078 = ImageAsset(name: "keycard_required_00078")
    static let keycardRequired00079 = ImageAsset(name: "keycard_required_00079")
    static let keycardRequired00080 = ImageAsset(name: "keycard_required_00080")
    static let keycardRequired00081 = ImageAsset(name: "keycard_required_00081")
    static let keycardRequired00082 = ImageAsset(name: "keycard_required_00082")
  }
  enum KeycardConfirmation {
    static let confirmed = ImageAsset(name: "confirmed")
    static let rejected = ImageAsset(name: "rejected")
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
    static let threeDotsDark = ImageAsset(name: "threeDotsDark")
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
    Keycard.keycardRequired00000,
    Keycard.keycardRequired00001,
    Keycard.keycardRequired00002,
    Keycard.keycardRequired00003,
    Keycard.keycardRequired00004,
    Keycard.keycardRequired00005,
    Keycard.keycardRequired00006,
    Keycard.keycardRequired00007,
    Keycard.keycardRequired00008,
    Keycard.keycardRequired00009,
    Keycard.keycardRequired00010,
    Keycard.keycardRequired00011,
    Keycard.keycardRequired00012,
    Keycard.keycardRequired00013,
    Keycard.keycardRequired00014,
    Keycard.keycardRequired00015,
    Keycard.keycardRequired00016,
    Keycard.keycardRequired00017,
    Keycard.keycardRequired00018,
    Keycard.keycardRequired00019,
    Keycard.keycardRequired00020,
    Keycard.keycardRequired00021,
    Keycard.keycardRequired00022,
    Keycard.keycardRequired00023,
    Keycard.keycardRequired00024,
    Keycard.keycardRequired00025,
    Keycard.keycardRequired00026,
    Keycard.keycardRequired00027,
    Keycard.keycardRequired00028,
    Keycard.keycardRequired00029,
    Keycard.keycardRequired00030,
    Keycard.keycardRequired00031,
    Keycard.keycardRequired00032,
    Keycard.keycardRequired00033,
    Keycard.keycardRequired00034,
    Keycard.keycardRequired00035,
    Keycard.keycardRequired00036,
    Keycard.keycardRequired00037,
    Keycard.keycardRequired00038,
    Keycard.keycardRequired00039,
    Keycard.keycardRequired00040,
    Keycard.keycardRequired00041,
    Keycard.keycardRequired00042,
    Keycard.keycardRequired00043,
    Keycard.keycardRequired00044,
    Keycard.keycardRequired00045,
    Keycard.keycardRequired00046,
    Keycard.keycardRequired00047,
    Keycard.keycardRequired00048,
    Keycard.keycardRequired00049,
    Keycard.keycardRequired00050,
    Keycard.keycardRequired00051,
    Keycard.keycardRequired00052,
    Keycard.keycardRequired00053,
    Keycard.keycardRequired00054,
    Keycard.keycardRequired00055,
    Keycard.keycardRequired00056,
    Keycard.keycardRequired00057,
    Keycard.keycardRequired00058,
    Keycard.keycardRequired00059,
    Keycard.keycardRequired00060,
    Keycard.keycardRequired00061,
    Keycard.keycardRequired00062,
    Keycard.keycardRequired00063,
    Keycard.keycardRequired00064,
    Keycard.keycardRequired00065,
    Keycard.keycardRequired00066,
    Keycard.keycardRequired00067,
    Keycard.keycardRequired00068,
    Keycard.keycardRequired00069,
    Keycard.keycardRequired00070,
    Keycard.keycardRequired00071,
    Keycard.keycardRequired00072,
    Keycard.keycardRequired00073,
    Keycard.keycardRequired00074,
    Keycard.keycardRequired00075,
    Keycard.keycardRequired00076,
    Keycard.keycardRequired00077,
    Keycard.keycardRequired00078,
    Keycard.keycardRequired00079,
    Keycard.keycardRequired00080,
    Keycard.keycardRequired00081,
    Keycard.keycardRequired00082,
    KeycardConfirmation.confirmed,
    KeycardConfirmation.rejected,
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
    TransferView.threeDotsDark,
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
