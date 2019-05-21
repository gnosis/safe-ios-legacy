// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSColor
  typealias Color = NSColor
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIColor
  typealias Color = UIColor
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable operator_usage_whitespace
extension Color {
  convenience init(rgbaValue: UInt32) {
    let red   = CGFloat((rgbaValue >> 24) & 0xff) / 255.0
    let green = CGFloat((rgbaValue >> 16) & 0xff) / 255.0
    let blue  = CGFloat((rgbaValue >>  8) & 0xff) / 255.0
    let alpha = CGFloat((rgbaValue      ) & 0xff) / 255.0

    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }
}
// swiftlint:enable operator_usage_whitespace

// swiftlint:disable identifier_name line_length type_body_length
struct ColorName {
  let rgbaValue: UInt32
  var color: Color { return Color(named: self) }

  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#00b8e0"></span>
  /// Alpha: 100% <br/> (0x00b8e0ff)
  static let aquaBlue = ColorName(rgbaValue: 0x00b8e0ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#65707e"></span>
  /// Alpha: 100% <br/> (0x65707eff)
  static let battleshipGrey = ColorName(rgbaValue: 0x65707eff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#c8ced4"></span>
  /// Alpha: 100% <br/> (0xc8ced4ff)
  static let borderGrey = ColorName(rgbaValue: 0xc8ced4ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#28b2fa"></span>
  /// Alpha: 100% <br/> (0x28b2faff)
  static let darkSkyBlue = ColorName(rgbaValue: 0x28b2faff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#0888cb"></span>
  /// Alpha: 100% <br/> (0x0888cbff)
  static let darkAzure = ColorName(rgbaValue: 0x0888cbff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#21435a"></span>
  /// Alpha: 100% <br/> (0x21435aff)
  static let darkSlateBlue = ColorName(rgbaValue: 0x21435aff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#4a5579"></span>
  /// Alpha: 100% <br/> (0x4a5579ff)
  static let dusk = ColorName(rgbaValue: 0x4a5579ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#09a862"></span>
  /// Alpha: 100% <br/> (0x09a862ff)
  static let greenTeal = ColorName(rgbaValue: 0x09a862ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#401d9c"></span>
  /// Alpha: 100% <br/> (0x401d9cff)
  static let indigoBlue = ColorName(rgbaValue: 0x401d9cff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#c6d2d9"></span>
  /// Alpha: 100% <br/> (0xc6d2d9ff)
  static let lightBlueGrey58 = ColorName(rgbaValue: 0xc6d2d9ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#a2a8ba"></span>
  /// Alpha: 100% <br/> (0xa2a8baff)
  static let lightGreyBlue = ColorName(rgbaValue: 0xa2a8baff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#e5e5ea"></span>
  /// Alpha: 100% <br/> (0xe5e5eaff)
  static let paleLilac = ColorName(rgbaValue: 0xe5e5eaff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#f4f5f9"></span>
  /// Alpha: 100% <br/> (0xf4f5f9ff)
  static let paleGrey = ColorName(rgbaValue: 0xf4f5f9ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#e3e5ec"></span>
  /// Alpha: 100% <br/> (0xe3e5ecff)
  static let paleGreyFour = ColorName(rgbaValue: 0xe3e5ecff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#efeff4"></span>
  /// Alpha: 100% <br/> (0xefeff4ff)
  static let paleGreyThree = ColorName(rgbaValue: 0xefeff4ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#e5e5ea"></span>
  /// Alpha: 100% <br/> (0xe5e5eaff)
  static let paleGreyTwo = ColorName(rgbaValue: 0xe5e5eaff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#d1d1d6"></span>
  /// Alpha: 100% <br/> (0xd1d1d6ff)
  static let silver = ColorName(rgbaValue: 0xd1d1d6ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#5ac8fa"></span>
  /// Alpha: 100% <br/> (0x5ac8faff)
  static let skyBlue = ColorName(rgbaValue: 0x5ac8faff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ff9500"></span>
  /// Alpha: 100% <br/> (0xff9500ff)
  static let tangerine = ColorName(rgbaValue: 0xff9500ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#f02525"></span>
  /// Alpha: 100% <br/> (0xf02525ff)
  static let tomato = ColorName(rgbaValue: 0xf02525ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#f02525"></span>
  /// Alpha: 15% <br/> (0xf0252527)
  static let tomato15 = ColorName(rgbaValue: 0xf0252527)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#f9fafc"></span>
  /// Alpha: 100% <br/> (0xf9fafcff)
  static let transparentWhiteOnGrey = ColorName(rgbaValue: 0xf9fafcff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#d8d8d8"></span>
  /// Alpha: 100% <br/> (0xd8d8d8ff)
  static let whiteTwo = ColorName(rgbaValue: 0xd8d8d8ff)
}
// swiftlint:enable identifier_name line_length type_body_length

extension Color {
  convenience init(named color: ColorName) {
    self.init(rgbaValue: color.rgbaValue)
  }
}
