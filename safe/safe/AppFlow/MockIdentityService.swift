//
//  Copyright © 2018 Gnosis. All rights reserved.
//

@testable import safe

final class MockIdentityService: IdentityApplicationService {

    private let mockStore = MockSecureStore()
    override var store: SecureStore { return mockStore }

}
