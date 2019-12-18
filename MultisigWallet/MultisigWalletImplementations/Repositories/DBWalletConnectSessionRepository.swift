//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import CommonImplementations
import Database

// swiftlint:disable:next line_length
public class DBWalletConnectSessionRepository: DBEntityRepository<WCSession, WCSessionID>, WalletConnectSessionRepository {

    public override var table: TableSchema {
        return .init("tbl_wc_sessions",
                     "topic TEXT NOT NULL PRIMARY KEY",
                     "url BLOB",
                     "dapp_info BLOB",
                     "wallet_info BLOB",
                     "status TEXT",
                     "created TEXT NOT NULL")
    }

    public override func insertionBindings(_ object: WCSession) -> [SQLBindable?] {
        return bindable([object.url.topic,
                         object.url.data,
                         object.dAppInfo.data,
                         object.walletInfo?.data,
                         object.status.rawValue,
                         object.created])
    }

    public override func objectFromResultSet(_ rs: ResultSet) throws -> WCSession? {
        guard let urlData: Data = rs["url"],
            let url = MultisigWalletDomainModel.WCURL(data: urlData),
            let dAppInfoData: Data = rs["dapp_info"],
            let dAppInfo = WCDAppInfo(data: dAppInfoData),
            let statusData: String = rs["status"],
            let status = WCSessionStatus(rawValue: statusData),
            let created = Date(serializedValue: rs["created"]) else { return nil }
        var walletInfo: WCWalletInfo?
        if let walletInfoData: Data = rs["wallet_info"] {
            walletInfo = WCWalletInfo(data: walletInfoData)
        }
        return WCSession(url: url, dAppInfo: dAppInfo, walletInfo: walletInfo, status: status, created: created)
    }

}

extension MultisigWalletDomainModel.WCURL {

    init?(data: Data) {
        guard let url = try? JSONDecoder().decode(MultisigWalletDomainModel.WCURL.self, from: data) else { return nil }
        self = url
    }

    var data: Data {
        return try! JSONEncoder().encode(self)
    }

}

extension WCDAppInfo: Codable {

    init?(data: Data) {
        do {
            self = try JSONDecoder().decode(WCDAppInfo.self, from: data)
        } catch {
            assertionFailure("Failed to decode: \(error)")
            return nil
        }
    }

    var data: Data {
        return try! JSONEncoder().encode(self)
    }

    enum CodingKeys: String, CodingKey {
        case peerId
        case peerMeta
        case isMobile
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let peerId = try container.decode(String.self, forKey: .peerId)
        let peerMeta = try container.decode(WCClientMeta.self, forKey: .peerMeta)
        // this is a new field, so it can be absent in encoded data of the previous versions
        let isMobile = try container.decodeIfPresent(Bool.self, forKey: .isMobile) ?? false
        self.init(peerId: peerId, peerMeta: peerMeta, isMobile: isMobile)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(peerId, forKey: .peerId)
        try container.encode(peerMeta, forKey: .peerMeta)
        try container.encode(isMobile, forKey: .isMobile)
    }

}

extension WCWalletInfo {

    init?(data: Data) {
        guard let info = try? JSONDecoder().decode(WCWalletInfo.self, from: data) else { return nil }
        self = info
    }

    var data: Data {
        return try! JSONEncoder().encode(self)
    }

}
