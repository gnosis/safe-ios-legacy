//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import CoreNFC
import Keycard
import MultisigWalletApplication

// General
//
//  - Keycard Transieving errors:
//      - CoreNFCCardChannel.Error.invalidAPDU if the KeycardSDK creates invalid APDU data struct (should not happen)
//      - NFCReaderError.* if any NFC error encountered during sending the command, including
//      user cancelling NFC reading, timeout, connection loss and others. This is likely to happen.
//
//   -  if failed to send the SELECT command to the card:
//      - Keycard SDK caused by invalid response received from the card (unlikely to happen):
//          - TLVError.endOfTLV if failed to parse response data
//          - TLVError.unexpectedTag if failed to parse the response data
//          - TLVError.unexpectedLength if failed to parse response data
class KeycardErrorConverter {

    enum Strings {
        static let lostConnection = LocalizedString("tag_connection_lost", comment: "Lost connection")
        static let genericError = LocalizedString("operation_failed", comment: "Operation failed")
    }


    static func errorMessageFromOperationFailure(_ error: Error) -> String {
        if let nfcError = error as? NFCReaderError,
            nfcError.code == NFCReaderError.readerTransceiveErrorTagConnectionLost {
            return Strings.lostConnection
        } else {
            return Strings.genericError
        }
    }

    static func convertFromNFCReaderError(_ error: Error) -> Error {
        guard let readerError = error as? NFCReaderError else { return error }
        switch readerError.code {

        case NFCReaderError.readerSessionInvalidationErrorSessionTimeout,
             NFCReaderError.readerSessionInvalidationErrorSessionTerminatedUnexpectedly:
            return KeycardApplicationService.Error.timeout

        case NFCReaderError.readerSessionInvalidationErrorUserCanceled,
             NFCReaderError.readerSessionInvalidationErrorSystemIsBusy:
            return KeycardApplicationService.Error.userCancelled

        default: return error
        }
    }

    //
    // Here are possible errors according to the SDK API docs:
    // from PAIR first step (P1=0x00) command:
    //   - 0x6A80 if the data is in the wrong format.
    //     Not expected at this point because SDK handles it
    //   - 0x6982 if client cryptogram verification fails.
    //     Not expected at this point because SDK sends random challenge.
    //   - 0x6A84 if all available pairing slot are taken.
    //     This can happen - StatusWord.allPairingSlotsTaken
    //   - 0x6A86 if P1 is invalid or is 0x01 but the first phase was not completed
    //     This should not happen as SDK should do it properly.
    //   - 0x6985 if a secure channel is open
    //     This should not happen because if existingPairing == nil then we
    //     did not open secure channel yet.
    //
    // from PAIR second step (P1=0x01) command:
    //   - 0x6A80 if the data is in the wrong format.
    //     Not expected at this point because SDK handles it
    //   - 0x6982 if client cryptogram verification fails.
    //     This may happen because the pairing password is invalid.
    //     (StatusWord.securityConditionNotSatisfied)
    //   - 0x6A84 if all available pairing slot are taken.
    //     This can happen - StatusWord.allPairingSlotsTaken
    //   - 0x6A86 if P1 is invalid or is 0x01 but the first phase was not completed
    //     This should not happen as SDK should do it properly.
    //   - 0x6985 if a secure channel is open
    //     This should not happen because if existingPairing == nil then we
    //     did not open secure channel yet.
    //
    // CardError.invalidAuthData - if our pairing password does not match card's cryptogram
    //

    static func convertFromPairingError(_ error: Error) -> Error {
        switch error {
        case StatusWord.allPairingSlotsTaken:
            return KeycardDomainServiceError.noPairingSlotsRemaining
        case CardError.invalidAuthData, StatusWord.securityConditionNotSatisfied:
            return KeycardDomainServiceError.invalidPairingPassword
        default:
            return error
        }
    }

    // possible errors:
    //   - CardError.notPaired: if the cmdSet.pairing is not set
    //     (developer error, should not happen)
    //   - CardError.invalidAuthData: if the SDK did not authenticate the card, might happen.
    // from OPEN SECURE CHANNEL command:
    //   - 0x6A86 if P1 is invalid: means that StatusWord.pairingIndexInvalid
    //   - 0x6A80 if the data is not a public key: means that StatusWord.dataInvalid
    //   - 0x6982 if a MAC cannot be verified: means that StatusWord.securityConditionNotSatisfied
    // from MUTUALLY AUTHENTICATE command:
    //   - 0x6985 if the previous successfully executed APDU was not OPEN SECURE CHANNEL.
    //     This error should not happen unless there is error in Keycard SDK
    //   - 0x6982 if authentication failed or the data is not 256-bit long
    //     (StatusWord.securityConditionNotSatisfied). This indicates that the card
    //     did not authenticate the app.
    //
    static func isPairingWithExistingDataFailed(_ error: Error) -> Bool {
        switch error {
            case CardError.invalidAuthData,
                 StatusWord.pairingIndexInvalid,
                 StatusWord.dataInvalid,
                 StatusWord.securityConditionNotSatisfied:
            return true
        default:
            return false
        }
    }

    // Possible errors:
    //   - 0x63CX on failure, where X is the number of attempt remaining
    //   - 0x63C0 when the PIN is blocked, even if the PIN is inserted correctly.
    static func convertFromAuthenticationError(_ error: Error) -> Error {
        switch error {
        case CardError.wrongPIN(retryCounter: let attempts):
            return attempts == 0 ?
                KeycardDomainServiceError.keycardBlocked :
                KeycardDomainServiceError.invalidPin(attempts)
        default:
            return error
        }
    }

    static func convertFromUnblockError(_ error: Error) -> Error {
        switch error {
        case CardError.wrongPIN(retryCounter: let attempts):
            return attempts == 0 ?
                KeycardDomainServiceError.keycardLost :
                KeycardDomainServiceError.invalidPUK(attempts)

        default:
            return error
        }
    }

}
