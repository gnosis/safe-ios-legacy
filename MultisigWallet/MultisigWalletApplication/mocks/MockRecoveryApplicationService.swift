//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public class MockRecoveryApplicationService: RecoveryApplicationService {

    public override func isRecoveryInProgress() -> Bool {
        return false
    }

    public override func resumeRecoveryInBackground() {
        // empty
    }

}
