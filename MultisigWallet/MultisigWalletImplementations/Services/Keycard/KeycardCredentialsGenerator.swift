//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

struct KeycardCredentialsGenerator {

    struct Params {
        var pinPukAlphabet: String
        var passwordAlphabet: String
        var pinLength: Int
        var pukLength: Int
        var pairingPasswordLength: Int

        static var `default` = Params(pinPukAlphabet: "0123456789",
                                      passwordAlphabet: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890+-=!@$#*&?",
                                      pinLength: 6,
                                      pukLength: 12,
                                      pairingPasswordLength: 12)
    }

    /// This method will generate valid credentials for initializing the Keycard.
    ///
    /// requires:
    ///   - nothing
    /// guarantees:
    ///   - pin generated as a 6-digit random string
    ///   - puk generated as a 12-digit random string
    ///   - pairingPassword generated asa 12-character alpha-numeric-symbol string
    public func generateCredentials(params: Params = .default) -> (pin: String, puk: String, pairingPassword: String) {
        return (pin: randomString(of: params.pinLength, alphabet: params.pinPukAlphabet),
                puk: randomString(of: params.pukLength, alphabet: params.pinPukAlphabet),
                pairingPassword: randomString(of: params.pairingPasswordLength,
                                              alphabet: params.passwordAlphabet))
    }

    // simple N out of M random algorithm. Did not use more advanced idea in lieu of simplicity.
    // requires:
    //    - nothing
    // guarantees:
    //   - for positive length and non-empty alphabet,
    //   string of `length` random characters from the alphabet is returned
    func randomString(of length: Int, alphabet: String) -> String {
        guard length > 0 && !alphabet.isEmpty else { return "" }
        return (0..<length).map { _ in String(alphabet.randomElement()!) }.joined()
    }

}
