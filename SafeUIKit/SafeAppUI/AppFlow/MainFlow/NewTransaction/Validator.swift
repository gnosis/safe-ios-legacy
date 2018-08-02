//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

protocol Validator {
    associatedtype ErrorType: Error
    func validate(_ value: String) -> ErrorType?
}
