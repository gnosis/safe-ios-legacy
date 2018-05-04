//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

extension UIDevice {

    var isSimulator: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }

}
