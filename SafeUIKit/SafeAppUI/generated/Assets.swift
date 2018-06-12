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
  static let faceIdIcon = ImageAsset(name: "face-id-icon")
  enum MainScreenHeader {
    static let arrows = ImageAsset(name: "arrows")
    static let arrowsGrey = ImageAsset(name: "arrows_grey")
    static let coins = ImageAsset(name: "coins")
    static let coinsGrey = ImageAsset(name: "coins_grey")
    static let gnosisSafeLogo = ImageAsset(name: "gnosis-safe-logo")
    static let qrcodeScan = ImageAsset(name: "qrcode-scan")
    static let send = ImageAsset(name: "send")
    static let settingsButtonIcon = ImageAsset(name: "settings-button-icon")
  }
  enum TokenIcons {
    static let ada = ImageAsset(name: "ADA")
    static let ae = ImageAsset(name: "AE")
    static let aion = ImageAsset(name: "AION")
    static let ardr = ImageAsset(name: "ARDR")
    static let ark = ImageAsset(name: "ARK")
    static let bat = ImageAsset(name: "BAT")
    static let bcd = ImageAsset(name: "BCD")
    static let bch = ImageAsset(name: "BCH")
    static let bcn = ImageAsset(name: "BCN")
    static let bix = ImageAsset(name: "BIX")
    static let bnb = ImageAsset(name: "BNB")
    static let bnt = ImageAsset(name: "BNT")
    static let btc = ImageAsset(name: "BTC")
    static let btcp = ImageAsset(name: "BTCP")
    static let btg = ImageAsset(name: "BTG")
    static let btm = ImageAsset(name: "BTM")
    static let bts = ImageAsset(name: "BTS")
    static let cmt = ImageAsset(name: "CMT")
    static let cnx = ImageAsset(name: "CNX")
    static let dash = ImageAsset(name: "DASH")
    static let dcn = ImageAsset(name: "DCN")
    static let dcr = ImageAsset(name: "DCR")
    static let ddd = ImageAsset(name: "DDD")
    static let dgb = ImageAsset(name: "DGB")
    static let dgd = ImageAsset(name: "DGD")
    static let doge = ImageAsset(name: "DOGE")
    static let drgn = ImageAsset(name: "DRGN")
    static let ela = ImageAsset(name: "ELA")
    static let elf = ImageAsset(name: "ELF")
    static let emc = ImageAsset(name: "EMC")
    static let eos = ImageAsset(name: "EOS")
    static let etc = ImageAsset(name: "ETC")
    static let eth = ImageAsset(name: "ETH")
    static let ethos = ImageAsset(name: "ETHOS")
    static let etn = ImageAsset(name: "ETN")
    static let fsn = ImageAsset(name: "FSN")
    static let fun = ImageAsset(name: "FUN")
    static let gas = ImageAsset(name: "GAS")
    static let gnt = ImageAsset(name: "GNT")
    static let gxs = ImageAsset(name: "GXS")
    static let hsr = ImageAsset(name: "HSR")
    static let ht = ImageAsset(name: "HT")
    static let icx = ImageAsset(name: "ICX")
    static let iost = ImageAsset(name: "IOST")
    static let kin = ImageAsset(name: "KIN")
    static let kmd = ImageAsset(name: "KMD")
    static let knc = ImageAsset(name: "KNC")
    static let lrc = ImageAsset(name: "LRC")
    static let lsk = ImageAsset(name: "LSK")
    static let ltc = ImageAsset(name: "LTC")
    static let maid = ImageAsset(name: "MAID")
    static let mkr = ImageAsset(name: "MKR")
    static let mona = ImageAsset(name: "MONA")
    static let nas = ImageAsset(name: "NAS")
    static let neo = ImageAsset(name: "NEO")
    static let nuls = ImageAsset(name: "NULS")
    static let nxt = ImageAsset(name: "NXT")
    static let omg = ImageAsset(name: "OMG")
    static let ont = ImageAsset(name: "ONT")
    static let pivx = ImageAsset(name: "PIVX")
    static let poly = ImageAsset(name: "POLY")
    static let ppt = ImageAsset(name: "PPT")
    static let qash = ImageAsset(name: "QASH")
    static let qtum = ImageAsset(name: "QTUM")
    static let rdd = ImageAsset(name: "RDD")
    static let rep = ImageAsset(name: "REP")
    static let rhoc = ImageAsset(name: "RHOC")
    static let sc = ImageAsset(name: "SC")
    static let sky = ImageAsset(name: "SKY")
    static let snt = ImageAsset(name: "SNT")
    static let steem = ImageAsset(name: "STEEM")
    static let strat = ImageAsset(name: "STRAT")
    static let sub = ImageAsset(name: "SUB")
    static let sys = ImageAsset(name: "SYS")
    static let theta = ImageAsset(name: "THETA")
    static let trx = ImageAsset(name: "TRX")
    static let usdt = ImageAsset(name: "USDT")
    static let ven = ImageAsset(name: "VEN")
    static let veri = ImageAsset(name: "VERI")
    static let wan = ImageAsset(name: "WAN")
    static let waves = ImageAsset(name: "WAVES")
    static let wtc = ImageAsset(name: "WTC")
    static let xem = ImageAsset(name: "XEM")
    static let xin = ImageAsset(name: "XIN")
    static let xlm = ImageAsset(name: "XLM")
    static let xmr = ImageAsset(name: "XMR")
    static let xrp = ImageAsset(name: "XRP")
    static let xvg = ImageAsset(name: "XVG")
    static let xzc = ImageAsset(name: "XZC")
    static let zec = ImageAsset(name: "ZEC")
    static let zil = ImageAsset(name: "ZIL")
    static let zrx = ImageAsset(name: "ZRX")
    static let defaultToken = ImageAsset(name: "default-token")
  }
  static let touchIdIcon = ImageAsset(name: "touch-id-icon")
  enum TransactionOverviewIcons {
    static let error = ImageAsset(name: "error")
    static let receive = ImageAsset(name: "receive")
    static let sent = ImageAsset(name: "sent")
    static let settingTransaction = ImageAsset(name: "setting_transaction")
    static let settingTransactionIcon = ImageAsset(name: "setting_transaction_icon")
  }

  // swiftlint:disable trailing_comma
  static let allColors: [ColorAsset] = [
  ]
  static let allImages: [ImageAsset] = [
    faceIdIcon,
    MainScreenHeader.arrows,
    MainScreenHeader.arrowsGrey,
    MainScreenHeader.coins,
    MainScreenHeader.coinsGrey,
    MainScreenHeader.gnosisSafeLogo,
    MainScreenHeader.qrcodeScan,
    MainScreenHeader.send,
    MainScreenHeader.settingsButtonIcon,
    TokenIcons.ada,
    TokenIcons.ae,
    TokenIcons.aion,
    TokenIcons.ardr,
    TokenIcons.ark,
    TokenIcons.bat,
    TokenIcons.bcd,
    TokenIcons.bch,
    TokenIcons.bcn,
    TokenIcons.bix,
    TokenIcons.bnb,
    TokenIcons.bnt,
    TokenIcons.btc,
    TokenIcons.btcp,
    TokenIcons.btg,
    TokenIcons.btm,
    TokenIcons.bts,
    TokenIcons.cmt,
    TokenIcons.cnx,
    TokenIcons.dash,
    TokenIcons.dcn,
    TokenIcons.dcr,
    TokenIcons.ddd,
    TokenIcons.dgb,
    TokenIcons.dgd,
    TokenIcons.doge,
    TokenIcons.drgn,
    TokenIcons.ela,
    TokenIcons.elf,
    TokenIcons.emc,
    TokenIcons.eos,
    TokenIcons.etc,
    TokenIcons.eth,
    TokenIcons.ethos,
    TokenIcons.etn,
    TokenIcons.fsn,
    TokenIcons.fun,
    TokenIcons.gas,
    TokenIcons.gnt,
    TokenIcons.gxs,
    TokenIcons.hsr,
    TokenIcons.ht,
    TokenIcons.icx,
    TokenIcons.iost,
    TokenIcons.kin,
    TokenIcons.kmd,
    TokenIcons.knc,
    TokenIcons.lrc,
    TokenIcons.lsk,
    TokenIcons.ltc,
    TokenIcons.maid,
    TokenIcons.mkr,
    TokenIcons.mona,
    TokenIcons.nas,
    TokenIcons.neo,
    TokenIcons.nuls,
    TokenIcons.nxt,
    TokenIcons.omg,
    TokenIcons.ont,
    TokenIcons.pivx,
    TokenIcons.poly,
    TokenIcons.ppt,
    TokenIcons.qash,
    TokenIcons.qtum,
    TokenIcons.rdd,
    TokenIcons.rep,
    TokenIcons.rhoc,
    TokenIcons.sc,
    TokenIcons.sky,
    TokenIcons.snt,
    TokenIcons.steem,
    TokenIcons.strat,
    TokenIcons.sub,
    TokenIcons.sys,
    TokenIcons.theta,
    TokenIcons.trx,
    TokenIcons.usdt,
    TokenIcons.ven,
    TokenIcons.veri,
    TokenIcons.wan,
    TokenIcons.waves,
    TokenIcons.wtc,
    TokenIcons.xem,
    TokenIcons.xin,
    TokenIcons.xlm,
    TokenIcons.xmr,
    TokenIcons.xrp,
    TokenIcons.xvg,
    TokenIcons.xzc,
    TokenIcons.zec,
    TokenIcons.zil,
    TokenIcons.zrx,
    TokenIcons.defaultToken,
    touchIdIcon,
    TransactionOverviewIcons.error,
    TransactionOverviewIcons.receive,
    TransactionOverviewIcons.sent,
    TransactionOverviewIcons.settingTransaction,
    TransactionOverviewIcons.settingTransactionIcon,
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
