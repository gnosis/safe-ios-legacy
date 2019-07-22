//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common
import MultisigWalletDomainModel

public struct WCSessionData {

    public var id: BaseID
    public var imageURL: URL?
    public var title: String
    public var subtitle: String

    enum Strings {
        static let pleaseWait = LocalizedString("please_wait", comment: "Please wait...")
        static let connecting = LocalizedString("connecting", comment: "Connecting...")
    }

    public init(id: BaseID, imageURL: URL?, title: String, subtitle: String) {
        self.id = id
        self.imageURL = imageURL
        self.title = title
        self.subtitle = subtitle
    }

    init(wcSession: WCSession) {
        let meta = wcSession.dAppInfo.peerMeta
        self.init(id: wcSession.id,
                  imageURL: meta.icons.isEmpty ? nil : meta.icons[0],
                  title: wcSession.status == .connecting ? Strings.pleaseWait : meta.name,
                  subtitle: wcSession.status == .connecting ? Strings.connecting : meta.url.absoluteString)
    }

}
