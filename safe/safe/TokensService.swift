//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import FirebaseInstanceID
import CommonImplementations

final class TokensService: TokensDomainService {

    func pushToken() -> String? {
        let semaphore = DispatchSemaphore(value: 0)
        var token: String?
        InstanceID.instanceID().instanceID { result, error in
            if let error = error {
                LogService.shared.error("Can't get fcmToken", error: error)
            }
            token = result?.token
            semaphore.signal()
        }
        semaphore.wait()
        return token
    }

}
