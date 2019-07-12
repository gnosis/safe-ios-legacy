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
                     "peer_id TEXT NOT NULL PRIMARY KEY",
                     "url BLOB",
                     "dapp_info BLOB",
                     "wallet_info BLOB")
    }

    public override func insertionBindings(_ object: WCSession) -> [SQLBindable?] {
        return bindable([object.dAppInfo.peerId,
                         object.url.data,
                         object.dAppInfo.data,
                         object.walletInfo?.data])
    }

    public override func objectFromResultSet(_ rs: ResultSet) throws -> WCSession? {
        guard let urlData: Data = rs["url"],
            let url = MultisigWalletDomainModel.WCURL(data: urlData),
            let dAppInfoData: Data = rs["dapp_info"],
            let dAppInfo = WCDAppInfo(data: dAppInfoData),
            let walletInfoData: Data = rs["wallet_info"],
            let walletInfo = WCWalletInfo(data: walletInfoData) else { return nil }
        return WCSession(url: url, dAppInfo: dAppInfo, walletInfo: walletInfo, status: .connected)
    }

}
