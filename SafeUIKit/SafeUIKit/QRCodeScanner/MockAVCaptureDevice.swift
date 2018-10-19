//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import AVFoundation

class MockAVCaptureDevice: AVCaptureDevice {

    class func reset() {
        authorizationStatus_result = .authorized
        authorizationStatus_in_mediaType = nil
        requestAccess_in_mediaType = nil
        requestAccess_in_handler = nil
    }

    static var authorizationStatus_result: AVAuthorizationStatus = .authorized
    static var authorizationStatus_in_mediaType: AVMediaType?
    open override class func authorizationStatus(for mediaType: AVMediaType) -> AVAuthorizationStatus {
        authorizationStatus_in_mediaType = mediaType
        return authorizationStatus_result
    }

    static var requestAccess_in_mediaType: AVMediaType?
    static var requestAccess_in_handler: ((Bool) -> Swift.Void)?
    open override class func requestAccess(for mediaType: AVMediaType,
                                           completionHandler handler: @escaping (Bool) -> Swift.Void) {
        requestAccess_in_mediaType = mediaType
        requestAccess_in_handler = handler
    }

}
