//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

protocol SecureStore {

    func password() throws -> String?
    func savePassword(_ password: String) throws
    func removePassword() throws

}
