//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

extension WCURL {

    static let testURL = WCURL(topic: "topic1",
                               version: "1",
                               bridgeURL: URL(string: "http://test.com")!,
                               key: "key")

}

extension WCClientMeta {

    static let testMeta = WCClientMeta(name: "name",
                                       description: "description",
                                       icons: [],
                                       url: URL(string: "http://test.com")!)

}

extension WCDAppInfo {

    static let testDAppInfo = WCDAppInfo(peerId: "peer1", peerMeta: WCClientMeta.testMeta)

}

extension WCWalletInfo {

    static let testWalletInfo = WCWalletInfo(approved: true,
                                             accounts: [],
                                             chainId: 1,
                                             peerId: "peer1",
                                             peerMeta: WCClientMeta.testMeta)

}

extension WCSession {

    static let testSession = WCSession(url: MultisigWalletDomainModel.WCURL.testURL,
                                       dAppInfo: WCDAppInfo.testDAppInfo,
                                       walletInfo: WCWalletInfo.testWalletInfo,
                                       status: .connected)

}
