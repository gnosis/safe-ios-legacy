//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public enum Result<Value, Error: Swift.Error> {

    case success(Value)
    case failure(Error)

    public init(value: Value) {
        self = .success(value)
    }

    public init(error: Error) {
        self = .failure(error)
    }

}

public enum RequestError: Error {
    case unexpectedError
}

public protocol NotificationService {

    func pair(pairingRequest: PairingRequest) -> Result<Bool, RequestError>

}
