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
        self.init(domain: "idn2Swift",
                  code: Int(idn2Code),
                  userInfo: [NSLocalizedDescriptionKey: NSError.localizedString(from: idn2_rc(idn2Code))])
    }

    // this is based on the libidn2 documentation.
    static func localizedString(from idn2Code: idn2_rc) -> String {
        switch idn2Code {
        case IDN2_OK:
            assertionFailure("OK is not an error")
            fallthrough
        case IDN2_MALLOC,
             IDN2_NO_CODESET,
             IDN2_ICONV_FAIL,
             IDN2_ENCODING_ERROR,
             IDN2_NFC,
             IDN2_PUNYCODE_BIG_OUTPUT,
             IDN2_PUNYCODE_OVERFLOW,
             IDN2_INVALID_FLAGS:
            let format = LocalizedString("ios_idn_error_internal_format", comment: "Internal error %s")
            return String(format: format, Int(idn2Code.rawValue))

        case IDN2_PUNYCODE_BAD_INPUT:
            return LocalizedString("ios_error_idn_invalid_punycode", comment: "Punycode")

        case IDN2_TOO_BIG_DOMAIN:
            return LocalizedString("ios_error_idn_domain_too_big", comment: "Domain too big")

        case IDN2_TOO_BIG_LABEL:
            return LocalizedString("ios_error_idn_label_too_big", comment: "Label too big")

        case IDN2_INVALID_ALABEL:
            return LocalizedString("ios_error_idn_invalid_alabel", comment: "Invalid a-label")

        case IDN2_UALABEL_MISMATCH:
            return LocalizedString("ios_error_idn_ualabel_mismatch", comment: "Label mismatch")

        case IDN2_NOT_NFC:
            return LocalizedString("ios_error_idn_not_nfc", comment: "Invalid normalization")

        case IDN2_2HYPHEN:
            return LocalizedString("ios_error_idn_2hyphen", comment: "Forbidden two hyphens")

        case IDN2_HYPHEN_STARTEND:
            return LocalizedString("ios_error_idn_hyphen_startend", comment: "Forbidden hyphen at start or end")

        case IDN2_LEADING_COMBINING:
            return LocalizedString("ios_error_idn_leading_combining", comment: "Forbidden symbol")

        case IDN2_DISALLOWED:
            return LocalizedString("ios_error_idn_disallowed", comment: "Disallowed symbol")

        case IDN2_CONTEXTJ:
            return LocalizedString("ios_error_idn_contextj", comment: "Forbidden context-j symbol")

        case IDN2_CONTEXTJ_NO_RULE:
            return LocalizedString("ios_error_idn_contextj_no_rule", comment: "Forbidden context-j without rule")

        case IDN2_CONTEXTO:
            return LocalizedString("ios_error_idn_contexto", comment: "Forbiden context-o symbol")

        case IDN2_CONTEXTO_NO_RULE:
            return LocalizedString("ios_error_idn_contexto_no_rule", comment: "Forbidden context-o without rule")

        case IDN2_UNASSIGNED:
            return LocalizedString("ios_error_idn_unassigned", comment: "Forbidden unassigned symbol")

        case IDN2_BIDI:
            return LocalizedString("ios_error_idn_bidi", comment: "Forbidden bi-directional symbol")

        case IDN2_DOT_IN_LABEL:
            return LocalizedString("ios_error_idn_dot_in_label", comment: "Forbidden type of dot symbol")

        case IDN2_INVALID_TRANSITIONAL:
            return LocalizedString("ios_error_idn_invalid_transitional", comment: "Invalid transitional symbols")

        case IDN2_INVALID_NONTRANSITIONAL:
            return LocalizedString("ios_error_idn_invalid_nontransitional", comment: "Invalid non-transitional symbol")

        case IDN2_ALABEL_ROUNDTRIP_FAILED:
            return LocalizedString("ios_error_idn_alabel_roundtrip_failed", comment: "A-U label roundtrip failed")

        default:
            let format = LocalizedString("ios_idn_error_internal_format", comment: "Internal error %s")
            return String(format: format, Int(idn2Code.rawValue))
        }
    }

}
