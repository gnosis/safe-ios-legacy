//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class WCSessionID: BaseID {}

public struct WCURL: Hashable {

    public var topic: String
    public var version: String
    public var bridgeURL: URL
    public var key: String

    public init(topic: String, version: String, bridgeURL: URL, key: String) {
        self.topic = topic
        self.version = version
        self.bridgeURL = bridgeURL
        self.key = key
    }

}

public struct WCPeerMeta {

    public var url: URL
    public var name: String
    public var description: String
    public var icons: [URL]

    public init(url: URL, name: String, description: String, icons: [URL]) {
        self.url = url
        self.name = name
        self.description = description
        self.icons = icons
    }

}

public enum WCSessionStatus {

    case connected
    case disconnected
    case connecting
    case error(String)

}

public class WCSession: IdentifiableEntity<WCSessionID> {

    public let url: WCURL
    public var status: WCSessionStatus
    public var peerMeta: WCPeerMeta?

    public init(url: WCURL, status: WCSessionStatus, peerMeta: WCPeerMeta?) {
        self.url = url
        self.status = status
        self.peerMeta = peerMeta
        super.init(id: WCSessionID(String(url.hashValue)))
    }

}
