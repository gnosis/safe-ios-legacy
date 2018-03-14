//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

func NSLocalizedStringWithDefaultValue(_ key: String,
                                       _ tableName: String,
                                       _ bundle: Bundle,
                                       _ value: String,
                                       _ comment: String) -> String {
    return NSLocalizedString(key, tableName: tableName, bundle: bundle, value: value, comment: comment)
}

func NSLocalizedStringFromTableInBundle(_ key: String,
                                        _ tableName: String,
                                        _ bundle: Bundle,
                                        _ comment: String) -> String {
    return NSLocalizedString(key, tableName: tableName, bundle: bundle, comment: comment)
}

func NSLocalizedStringFromTable(_ key: String,
                                _ tableName: String,
                                _ comment: String) -> String {
    return NSLocalizedString(key, tableName: tableName, comment: comment)
}

func NSLocalizedString(_ key: String, _ comment: String) -> String {
    return NSLocalizedString(key, comment: comment)
}
