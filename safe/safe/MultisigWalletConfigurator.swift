//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common
import CommonImplementations
import Database
import MultisigWalletDomainModel
import MultisigWalletApplication
import MultisigWalletImplementations
import SafeAppUI

// swiftlint:disable function_body_length
class MultisigWalletConfigurator {

    class func configure(with appDelegate: AppDelegate) {
        let config = appDelegate.appConfig!
        let walletService = WalletApplicationService(configuration: config.walletApplicationServiceConfiguration)
        ApplicationServiceRegistry.put(service: walletService, for: WalletApplicationService.self)
        ApplicationServiceRegistry.put(service: RecoveryApplicationService(), for: RecoveryApplicationService.self)
        ApplicationServiceRegistry.put(service: WalletSettingsApplicationService(),
                                       for: WalletSettingsApplicationService.self)
        ApplicationServiceRegistry.put(service: LogService.shared, for: Logger.self)

        DomainRegistry.put(service: LogService.shared, for: Logger.self)
        let notificationService = HTTPNotificationService(url: config.notificationServiceURL,
                                                          logger: LogService.shared)
        DomainRegistry.put(service: notificationService, for: NotificationDomainService.self)
        let tokenService = HTTPTokenListService(url: config.relayServiceURL, logger: LogService.shared)
        DomainRegistry.put( service: tokenService, for: TokenListDomainService.self)
        DomainRegistry.put(service: PushTokensService(), for: PushTokensDomainService.self)
        DomainRegistry.put(service: AccountUpdateDomainService(), for: AccountUpdateDomainService.self)
        DomainRegistry.put(service: SynchronisationService(), for: SynchronisationDomainService.self)
        DomainRegistry.put(service: EventPublisher(), for: EventPublisher.self)
        DomainRegistry.put(service: System(), for: System.self)
        DomainRegistry.put(service: ErrorStream(), for: ErrorStream.self)
        DomainRegistry.put(service: DeploymentDomainService(), for: DeploymentDomainService.self)
        DomainRegistry.put(service: TransactionDomainService(), for: TransactionDomainService.self)
        DomainRegistry.put(service: RecoveryDomainService(), for: RecoveryDomainService.self)
        DomainRegistry.put(service: ReplaceBrowserExtensionDomainService(),
                           for: ReplaceBrowserExtensionDomainService.self)
        DomainRegistry.put(service: ConnectBrowserExtensionDomainService(),
                           for: ConnectBrowserExtensionDomainService.self)
        DomainRegistry.put(service: DisconnectBrowserExtensionDomainService(),
                           for: DisconnectBrowserExtensionDomainService.self)
        DomainRegistry.put(service: ReplaceRecoveryPhraseDomainService(),
                           for: ReplaceRecoveryPhraseDomainService.self)
        DomainRegistry.put(service: CommunicationDomainService(), for: CommunicationDomainService.self)
        DomainRegistry.put(service: InMemorySafeContractMetadataRepository(metadata: config.safeContractMetadata),
                           for: SafeContractMetadataRepository.self)


        let relay = EventRelay(publisher: DomainRegistry.eventPublisher)
        ApplicationServiceRegistry.put(service: relay, for: EventRelay.self)

        // temporal coupling with domain model's services
        ApplicationServiceRegistry
            .put(service: ReplaceBrowserExtensionApplicationService.create(),
                 for: ReplaceBrowserExtensionApplicationService.self)
        ApplicationServiceRegistry
            .put(service: ConnectBrowserExtensionApplicationService.create(),
                 for: ConnectBrowserExtensionApplicationService.self)
        ApplicationServiceRegistry
            .put(service: DisconnectBrowserExtensionApplicationService.createDisconnectService(),
                 for: DisconnectBrowserExtensionApplicationService.self)
        ApplicationServiceRegistry
            .put(service: ReplaceRecoveryPhraseApplicationService.create(),
                 for: ReplaceRecoveryPhraseApplicationService.self)

        configureEthereum(with: appDelegate)
        setUpMultisigDatabase(with: appDelegate)
        configureWalletConnect(chainId: config.encryptionServiceChainId)
    }

    class func setUpMultisigDatabase(with appDelegate: AppDelegate) {
        do {
            let db = SQLiteDatabase(name: "MultisigWallet",
                                    fileManager: FileManager.default,
                                    sqlite: DataProtectionAwareCSQLite3(filesystemGuard: appDelegate.filesystemGuard),
                                    bundleId: Bundle.main.bundleIdentifier ?? appDelegate.defaultBundleIdentifier)
            appDelegate.multisigWalletDB = db
            let walletRepo = DBWalletRepository(db: db)
            let portfolioRepo = DBSinglePortfolioRepository(db: db)
            let accountRepo = DBAccountRepository(db: db)
            let transactionRepo = DBTransactionRepository(db: db)
            let tokenListItemRepo = DBTokenListItemRepository(db: db)
            let monitorRepo = DBRBETransactionMonitorRepository(db: db)
            let migrationRepo = DBMigrationRepository(db: db)
            let migrationService = DBMigrationService(repository: migrationRepo)
            DomainRegistry.put(service: walletRepo, for: WalletRepository.self)
            DomainRegistry.put(service: portfolioRepo, for: SinglePortfolioRepository.self)
            DomainRegistry.put(service: accountRepo, for: AccountRepository.self)
            DomainRegistry.put(service: transactionRepo, for: TransactionRepository.self)
            DomainRegistry.put(service: tokenListItemRepo, for: TokenListItemRepository.self)
            DomainRegistry.put(service: monitorRepo, for: RBETransactionMonitorRepository.self)

            let noDatabase = !db.exists
            if noDatabase {
                try db.create()
            }

            portfolioRepo.setUp()
            walletRepo.setUp()
            accountRepo.setUp()
            transactionRepo.setUp()
            tokenListItemRepo.setUp()
            monitorRepo.setUp()
            migrationRepo.setUp()

            if noDatabase {
                skipMigrationsBeforeAndIncluding(WalletMigrations.latest, with: migrationService)
            }

            migrate(with: migrationService)
        } catch let e {
            ErrorHandler.showFatalError(log: "Failed to set up multisig database", error: e)
        }
    }

    /// Initially database should be created in it's final state. Here we add a latest migration number
    /// into tbl_migrations to skip all previous migrations.
    ///
    /// - Parameters:
    ///   - migration: Latest migration.
    ///   - migrationService: Migration service.
    private class func skipMigrationsBeforeAndIncluding(_ migration: Migration,
                                                        with migrationService: DBMigrationService) {
        precondition(Thread.isMainThread)
        do {
            try migrationService.skipMigrationsBeforeAndIncluding(migration)
        } catch {
            ApplicationServiceRegistry.logger.error("Failed to setup latest MultisigWallet migration", error: error)
        }
    }

    /// This method runs all migrations that have a number higher than the highest stored migration
    /// number in tbl_migrations.
    ///
    /// - Parameter migrationService: Migration service.
    private class func migrate(with migrationService: DBMigrationService) {
        precondition(Thread.isMainThread)
        do {
            migrationService.register(WalletMigrations.all)
            try migrationService.migrate()
        } catch {
            ApplicationServiceRegistry.logger.error("Failed to run MultisigWallet migrations", error: error)
        }
    }

    private class func configureEthereum(with appDelegate: AppDelegate) {
        let appConfig = appDelegate.appConfig!
        ApplicationServiceRegistry.put(service: EthereumApplicationService(), for: EthereumApplicationService.self)
        ApplicationServiceRegistry.put(service: LogService.shared, for: Logger.self)

        let chainId = EIP155ChainId(rawValue: appConfig.encryptionServiceChainId)!
        let encryptionService = MultisigWalletImplementations.EncryptionService(chainId: chainId)
        DomainRegistry.put(service: encryptionService, for: EncryptionDomainService.self)
        let relayService = HTTPGnosisTransactionRelayService(url: appConfig.relayServiceURL, logger: LogService.shared)
        DomainRegistry.put(service: relayService, for: TransactionRelayDomainService.self)

        appDelegate.secureStore = KeychainService(identifier: appDelegate.defaultBundleIdentifier)
        DomainRegistry.put(service: SecureExternallyOwnedAccountRepository(store: appDelegate.secureStore!),
                           for: ExternallyOwnedAccountRepository.self)

        let nodeService = InfuraEthereumNodeService(url: appConfig.nodeServiceConfig.url,
                                                    chainId: appConfig.nodeServiceConfig.chainId)
        DomainRegistry.put(service: nodeService, for: EthereumNodeDomainService.self)
    }

    private class func configureWalletConnect(chainId: Int) {
        DomainRegistry.put(service: WalletConnectService(), for: WalletConnectDomainService.self)
        DomainRegistry.put(service: InMemoryWCSessionRepository(), for: WalletConnectSessionRepository.self)
        ApplicationServiceRegistry.put(service: WalletConnectApplicationService(chainId: chainId),
                                       for: WalletConnectApplicationService.self)
    }

}
