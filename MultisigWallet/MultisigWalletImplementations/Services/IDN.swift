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

//// argument errors
//* @IDN2_PUNYCODE_BAD_INPUT: Punycode invalid input.
//* @IDN2_TOO_BIG_DOMAIN: Domain name longer than 255 characters.
//* @IDN2_TOO_BIG_LABEL: Domain label longer than 63 characters.
//* @IDN2_INVALID_ALABEL: Input A-label is not valid.
//* @IDN2_UALABEL_MISMATCH: Input A-label and U-label does not match.
//* @IDN2_NOT_NFC: String is not NFC.
//* @IDN2_2HYPHEN: String has forbidden two hyphens.
//* @IDN2_HYPHEN_STARTEND: String has forbidden starting/ending hyphen.
//* @IDN2_LEADING_COMBINING: String has forbidden leading combining character.
//* @IDN2_DISALLOWED: String has disallowed character.
//* @IDN2_CONTEXTJ: String has forbidden context-j character.
//* @IDN2_CONTEXTJ_NO_RULE: String has context-j character with no rule.
//* @IDN2_CONTEXTO: String has forbidden context-o character.
//* @IDN2_CONTEXTO_NO_RULE: String has context-o character with no rule.
//* @IDN2_UNASSIGNED: String has forbidden unassigned character.
//* @IDN2_BIDI: String has forbidden bi-directional properties.
//* @IDN2_DOT_IN_LABEL: Label has forbidden dot (TR46).
//* @IDN2_INVALID_TRANSITIONAL: Label has character forbidden in transitional mode (TR46).
//* @IDN2_INVALID_NONTRANSITIONAL: Label has character forbidden in non-transitional mode (TR46).
//* @IDN2_ALABEL_ROUNDTRIP_FAILED: ALabel -> Ulabel -> ALabel result differs from input.
//
//// internal errors:
//* @IDN2_MALLOC: Memory allocation error.
//* @IDN2_NO_CODESET: Could not determine locale string encoding format.
//* @IDN2_ICONV_FAIL: Could not transcode locale string to UTF-8.
//* @IDN2_ENCODING_ERROR: Unicode data encoding error.
//* @IDN2_PUNYCODE_BIG_OUTPUT: Punycode output buffer too small.
//* @IDN2_PUNYCODE_OVERFLOW: Punycode conversion would overflow.
//* @IDN2_INVALID_FLAGS: Invalid combination of flags.
//* @IDN2_NFC: Error normalizing string.
