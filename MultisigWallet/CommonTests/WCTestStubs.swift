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

    static let testURL2 = WCURL(topic: "topic2",
                                version: "1",
                                bridgeURL: URL(string: "http://test.com")!,
                                key: "key2")

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

    static let testWalletInfo = test(accounts: [])

    static func test(accounts: [String]) -> WCWalletInfo {
        WCWalletInfo(approved: true,
                     accounts: accounts,
                     chainId: 1,
                     peerId: "peer1",
                     peerMeta: WCClientMeta.testMeta)
    }


}

extension WCSession {

    static let testSession = test(walletInfo: WCWalletInfo.testWalletInfo)

    static let connectingTestSession = WCSession(url: MultisigWalletDomainModel.WCURL.testURL2,
                                                 dAppInfo: WCDAppInfo.testDAppInfo,
                                                 walletInfo: nil,
                                                 status: .connecting,
                                                 created: Date(timeIntervalSince1970: 10_000))

    static func test(walletInfo: WCWalletInfo?) -> WCSession {
        WCSession(url: MultisigWalletDomainModel.WCURL.testURL,
                  dAppInfo: WCDAppInfo.testDAppInfo,
                  walletInfo: walletInfo,
                  status: .connected,
                  created: Date(timeIntervalSince1970: 20_000))
    }

}

extension WCMessage {

    static let testMessage = WCMessage(payload: "", url: WCURL.testURL)

}

extension WCSendTransactionRequest {

    static let testRequest = WCSendTransactionRequest(from: Address("0xCF4140193531B8b2d6864cA7486Ff2e18da5cA95"),
                                                      to: Address("0xCF4140193531B8b2d6864cA7486Ff2e18da5cA95"),
                                                      gasLimit: TokenInt(hex: "0x5208")!,
                                                      gasPrice: TokenInt(hex: "0x3b9aca00")!,
                                                      value: TokenInt(hex: "0x00")!,
                                                      data: Data(hex: "0x"),
                                                      nonce: "0x00")

    static func dangerousRequest() -> WCSendTransactionRequest {
        return WCSendTransactionRequest(from: Address("0xCF4140193531B8b2d6864cA7486Ff2e18da5cA95"),
                                        to: DomainRegistry.walletRepository.selectedWallet()!.address,
                                        gasLimit: TokenInt(hex: "0x5208")!,
                                        gasPrice: TokenInt(hex: "0x3b9aca00")!,
                                        value: TokenInt(hex: "0x00")!,
                                        data: Data(hex: "0x1"),
                                        nonce: "0x00")
    }


}
