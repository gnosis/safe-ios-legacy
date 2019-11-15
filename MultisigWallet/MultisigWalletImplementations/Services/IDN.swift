//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import idn2

// see https://unicode.org/reports/tr46/
// see https://libidn.gitlab.io/libidn2/manual/libidn2.html
final class IDN {

    private init() {}

    static func utf8ToASCII(_ utf8String: String, useSTD3ASCIIRules: Bool, transitionalProcessing: Bool = false) throws -> String {
        var flags: Int32 = 0
        flags |= Int32(IDN2_NFC_INPUT.rawValue)
        if useSTD3ASCIIRules {
            flags |= Int32(IDN2_USE_STD3_ASCII_RULES.rawValue)
        }
        if transitionalProcessing {
            flags |= Int32(IDN2_TRANSITIONAL.rawValue)
        }

        var input = Array(utf8String.utf8CString)
        var output: UnsafeMutablePointer<CChar>?
        let status = idn2_to_ascii_8z(&input, &output, flags)
        defer { free(output) }
        guard status == IDN2_OK.rawValue else {
            throw NSError(idn2Code: status)
        }
        let result = String(cString: output!)
        return result
    }

    static func asciiToUTF8(_ asciiString: String) throws -> String {
        var input = Array(asciiString.utf8CString)
        var output: UnsafeMutablePointer<CChar>?
        let unusedFlags: Int32 = 0
        let status = idn2_to_unicode_8z8z(&input, &output, unusedFlags)
        defer { free(output) }
        guard status == IDN2_OK.rawValue else {
            throw NSError(idn2Code: status)
        }
        let result = String(cString: output!)
        return result
    }

}

extension NSError {

    convenience init(idn2Code: Int32) {
        let errorMessage: String
        if let namePtr = idn2_strerror_name(idn2Code), let messagePtr = idn2_strerror(idn2Code) {
            let name = String(cString: namePtr)
            let message = String(cString: messagePtr)
            errorMessage = "\(name): \(message)"
        } else {
            errorMessage = "unknown error code"
        }
        self.init(domain: "idn2Swift",
                  code: Int(idn2Code),
                  userInfo: [NSLocalizedDescriptionKey: errorMessage])
    }

}
