//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common
import CommonImplementations
import Database
import IdentityAccessApplication
import IdentityAccessDomainModel
import IdentityAccessImplementations
import SafeAppUI

class IdentityAccessConfigurator {

    class func configure(with appDelegate: AppDelegate) {
        ApplicationServiceRegistry.put(service: AuthenticationApplicationService(),
                                       for: AuthenticationApplicationService.self)
        ApplicationServiceRegistry.put(service: SystemClockService(), for: Clock.self)
        ApplicationServiceRegistry.put(service: LogService.shared, for: Logger.self)
        DomainRegistry.put(service: BiometricService(), for: BiometricAuthenticationService.self)
        DomainRegistry.put(service: SystemClockService(), for: Clock.self)
        let encryptionService = IdentityAccessImplementations.CommonCryptoEncryptionService()
        DomainRegistry.put(service: encryptionService, for: EncryptionService.self)
        DomainRegistry.put(service: IdentityService(), for: IdentityService.self)
        setUpIdentityAccessDatabase(with: appDelegate)

    }

    class func setUpIdentityAccessDatabase(with appDelegate: AppDelegate) {
        do {
            let db = SQLiteDatabase(name: "IdentityAccess",
                                    fileManager: FileManager.default,
                                    sqlite: DataProtectionAwareCSQLite3(filesystemGuard: appDelegate.filesystemGuard),
                                    bundleId: Bundle.main.bundleIdentifier ?? appDelegate.defaultBundleIdentifier)
            appDelegate.identityAccessDB = db
            let userRepo = DBSingleUserRepository(db: db)
            let gatekeeperRepo = DBSingleGatekeeperRepository(db: db)
            DomainRegistry.put(service: userRepo, for: SingleUserRepository.self)
            DomainRegistry.put(service: gatekeeperRepo, for: SingleGatekeeperRepository.self)

            if !db.exists {
                try db.create()
                userRepo.setUp()
                gatekeeperRepo.setUp()

                try ApplicationServiceRegistry.authenticationService
                    .createAuthenticationPolicy(sessionDuration: 60,
                                                maxPasswordAttempts: 3,
                                                blockedPeriodDuration: 15)
            }

            let migrationRepo = DBMigrationRepository(db: db)
            migrationRepo.setUp()
            let migrationService = DBMigrationService(repository: migrationRepo)
            registerIdentityAccessDatabaseMigrations(service: migrationService)
            try migrationService.migrate()
        } catch let e {
            DispatchQueue.main.async {
                ErrorHandler.showFatalError(log: "Failed to set up identity access database",
                                            error: e,
                                            from: appDelegate.window!.rootViewController!)
            }
        }
    }

    private class func registerIdentityAccessDatabaseMigrations(service: DBMigrationService) {
        // identity access db migrations go here
    }

}
