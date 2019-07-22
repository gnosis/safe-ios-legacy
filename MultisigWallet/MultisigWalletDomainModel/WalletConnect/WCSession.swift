//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public struct WCURL: Codable, Equatable {

    public let topic: String
    public let version: String
    public let bridgeURL: URL
    public let key: String

    public init(topic: String, version: String, bridgeURL: URL, key: String) {
        self.topic = topic
        self.version = version
        self.bridgeURL = bridgeURL
        self.key = key
    }

}

public struct WCClientMeta: Codable {

    public let name: String
    public let description: String
    public let icons: [URL]
    public let url: URL

    public init(name: String, description: String, icons: [URL], url: URL) {
        self.name = name
        self.description = description
        self.icons = icons
        self.url = url
    }

}

public struct WCDAppInfo: Codable {

    public let peerId: String
    public let peerMeta: WCClientMeta

    public init(peerId: String, peerMeta: WCClientMeta) {
        self.peerId = peerId
        self.peerMeta = peerMeta
    }

}

public struct WCWalletInfo: Codable {

    public let approved: Bool
    public let accounts: [String]
    public let chainId: Int
    public let peerId: String
    public let peerMeta: WCClientMeta

    public init(approved: Bool, accounts: [String], chainId: Int, peerId: String, peerMeta: WCClientMeta) {
        self.approved = approved
        self.accounts = accounts
        self.chainId = chainId
        self.peerId = peerId
        self.peerMeta = peerMeta
    }

}

// Be careful with updating. Used in DB.
public enum WCSessionStatus: String, Codable {

    case connecting
    case connected
    case disconnected

}

public class WCSessionID: BaseID {}

public class WCSession: IdentifiableEntity<WCSessionID> {

    public let url: WCURL
    public let dAppInfo: WCDAppInfo
    public let walletInfo: WCWalletInfo?
    public let status: WCSessionStatus
    public let created: Date

    public init(url: WCURL,
                dAppInfo: WCDAppInfo,
                walletInfo: WCWalletInfo?,
                status: WCSessionStatus,
                created: Date = Date()) {
        self.url = url
        self.dAppInfo = dAppInfo
        self.walletInfo = walletInfo
        self.status = status
        self.created = created
        super.init(id: WCSessionID(String(url.topic)))
    }

}
