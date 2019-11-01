//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

/// Implements business logic required to deploy a multisignature wallet. Deployment is a multi-step process,
/// with every step could take significant amount of time. Nevertheless, the service itself is stateless and
/// all changes in the deployment process are recorded in other domain objects and stored in repositories.
public class DeploymentDomainService {

    private let config: DeploymentDomainServiceConfiguration
    internal var responseValidator = SafeCreationResponseValidator()
    private let repeaters = Repeaters()

    public init(_ config: DeploymentDomainServiceConfiguration = .standard) {
        self.config = config
    }

    public func start() {
        repeaters.stopAll() // to prevent spawning too many active threads waiting for wallet deployment

        DomainRegistry.eventPublisher.unsubscribe(self)

        subscribe(event: DeploymentStarted.self,                    action: prepareSafeCreationTransaction)
        subscribe(event: StartedWaitingForFirstDeposit.self,        action: waitForFirstDeposit)
        subscribe(event: StartedWaitingForRemainingFeeAmount.self,  action: waitForRemainingFeeAmount)
        subscribe(event: DeploymentFunded.self,                     action: startSafeCreation)
        subscribe(event: CreationStarted.self,                      action: waitUntilWalletIsReady)
        subscribe(event: WalletCreated.self,                        action: postProcessCreation)
        subscribe(event: WalletCreationFailed.self,                 action: crashTheApp)
        subscribe(event: DeploymentAborted.self,                    action: stopAllWalletDeploymentActivity)

        let walletsToCreate = DomainRegistry.walletRepository.filter(by: WalletState.State.creationStates)
        for wallet in walletsToCreate {
            wallet.resume()
        }
    }

    public func createNewDraftWallet() {
        let portfolio = WalletDomainService.fetchOrCreatePortfolio()
        let address = WalletDomainService.newOwner()
        let wallet = Wallet(id: DomainRegistry.walletRepository.nextID(), owner: address)
        let account = Account(tokenID: Token.Ether.id, walletID: wallet.id)
        portfolio.addWallet(wallet.id)
        portfolio.selectWallet(wallet.id)
        DomainRegistry.walletRepository.save(wallet)
        DomainRegistry.portfolioRepository.save(portfolio)
        DomainRegistry.accountRepository.save(account)
    }

    // MARK: -  Wallet Creation Stages

    func prepareSafeCreationTransaction(_ wallet: Wallet) throws {
        let owners = wallet.allOwners().map { $0.address }
        let request = SafeCreationRequest(saltNonce: DomainRegistry.encryptionService.randomSaltNonce(),
                                          owners: owners,
                                          confirmationCount: wallet.confirmationCount,
                                          paymentToken: wallet.feePaymentTokenAddress ?? Token.Ether.address)
        let response = try DomainRegistry.transactionRelayService.createSafeCreationTransaction(request: request)
        try responseValidator.validate(response, request: request)
        wallet.changeAddress(response.safeAddress)
        wallet.updateMinimumTransactionAmount(response.payment.value)
        wallet.changeMasterCopy(response.masterCopyAddress)
        let version = DomainRegistry.safeContractMetadataRepository.version(masterCopyAddress:
            response.masterCopyAddress)
        wallet.changeContractVersion(version)
        let firstSafe = WalletDomainService.fetchOrCreatePortfolio().wallets.count == 1
        let name = firstSafe ? "Safe" : "Safe \(response.safeAddress.value.suffix(4))"
        if DomainRegistry.addressBookRepository.find(address: wallet.address.value, types: [.wallet]).isEmpty {
            let addressBookEntry = AddressBookEntry(name: name, address: wallet.address.value, type: .wallet)
            DomainRegistry.addressBookRepository.save(addressBookEntry)
        }
        wallet.proceed()
    }

    func waitForFirstDeposit(_ wallet: Wallet) throws {
        try `repeat`(for: wallet, delay: config.balance.repeatDelay, closure: checkDidReceiveFirstDeposit)
    }

    func checkDidReceiveFirstDeposit(_ wallet: Wallet) throws -> Bool {
        guard wallet.isWaitingForFirstDeposit else { return false }
        let balance = try self.updateBalance(for: wallet)
        let hasDeposit = balance > 0
        if hasDeposit {
            wallet.proceed()
        }
        return hasDeposit
    }

    private func waitForRemainingFeeAmount(_ wallet: Wallet) throws {
        try `repeat`(for: wallet, delay: config.balance.repeatDelay, closure: checkHasMinimumAmount)
    }

    func checkHasMinimumAmount(_ wallet: Wallet) throws -> Bool {
        guard wallet.isWaitingForFunding else { return false }
        let balance = try self.updateBalance(for: wallet)
        let hasEnough = balance >= wallet.minimumDeploymentTransactionAmount
        if hasEnough {
            wallet.proceed()
        }
        return hasEnough
    }

    func startSafeCreation(_ wallet: Wallet) throws {
        try DomainRegistry.transactionRelayService.startSafeCreation(address: wallet.address)
        wallet.proceed()
    }

    func waitUntilWalletIsReady(_ wallet: Wallet) throws {
        DispatchQueue.global().async(execute: DomainRegistry.syncService.syncTokensAndAccountsOnce)

        if wallet.creationTransactionHash != nil {
            DomainRegistry.eventPublisher.publish(WalletTransactionHashIsKnown(wallet))
        } else {
            try `repeat`(for: wallet, delay: config.deploymentStatus.repeatDelay, closure: checkHasSubmittedTransaction)
        }

        if wallet.isReadyToUse { return }

        try `repeat`(for: wallet, delay: config.transactionStatus.repeatDelay, closure: checkHasMinedTransaction)
    }

    func checkHasSubmittedTransaction(_ wallet: Wallet) throws -> Bool {
        guard wallet.isFinalizingDeployment else { return false }
        guard let hash = try self.transactionHash(of: wallet.address) else { return false }
        wallet.assignCreationTransaction(hash: hash.value)
        DomainRegistry.walletRepository.save(wallet)
        DomainRegistry.eventPublisher.publish(WalletTransactionHashIsKnown(wallet))
        return true
    }

    func checkHasMinedTransaction(_ wallet: Wallet) throws -> Bool {
        guard wallet.isFinalizingDeployment else { return false }
        guard let receipt = try self.receipt(of: TransactionHash(wallet.creationTransactionHash)) else { return false }
        if receipt.status == .success {
            wallet.proceed()
        } else {
            let userInfo: [String: Any] = [NSLocalizedDescriptionKey: "Creation transaction failed"]
            let error = NSError(domain: "DeploymentDomainService", code: -1, userInfo: userInfo)
            DomainRegistry.logger.error("Wallet creation transaction failed", error: error)
            wallet.cancel()
        }
        return true
    }

    func postProcessCreation(_ wallet: Wallet) throws {
        try DomainRegistry.communicationService.notifyWalletCreatedIfNeeded(walletID: wallet.id)
        let paperWalletAddress = wallet.owner(role: .paperWallet)!.address
        let derivedAddress = wallet.owner(role: .paperWalletDerived)!.address
        DomainRegistry.externallyOwnedAccountRepository.remove(address: paperWalletAddress)
        DomainRegistry.externallyOwnedAccountRepository.remove(address: derivedAddress)
    }

    func crashTheApp(_ wallet: Wallet) throws {
        // should we still crash the app if the wallet failed? probably not.
        // what then? then we should notify the user of it and ask to contact us.
        DomainRegistry.system.exit(EXIT_FAILURE)
    }

    func stopAllWalletDeploymentActivity(_ wallet: Wallet) throws {
        repeaters.stopAll(for: wallet.id)
    }

    // MARK: - Helper Functions

    /// Assigns a handler to a wallet event of certain type
    private func subscribe<T: WalletEvent>(event: T.Type, action: @escaping (Wallet) throws -> Void) {
        DomainRegistry.eventPublisher.subscribe(self, bind(event, action))
    }

    /// Wrapper for a wallet event handler
    private func bind<T: WalletEvent>(_ event: T.Type, _ action: @escaping (Wallet) throws -> Void) -> (T) -> Void {
        return { [unowned self] event in
            self.executeInWallet(for: event, action)
        }
    }

    /// Fetches a wallet for the event and executes a closure. Handles errors arrising from the closure.
    /// For an error that is not a NetworkServiceError, or a NSURLErrorDomain, the wallet deployment will be cancelled.
    /// This would trigger the "DeploymentAborted" event implicitly through the change of wallet state.
    func executeInWallet(for event: WalletEvent, _ closure: (Wallet) throws -> Void) {
        guard let wallet = DomainRegistry.walletRepository.find(id: event.walletID) else { return }
        do {
            try closure(wallet)
        } catch let error {
            DomainRegistry.errorStream.post(error)
            switch error {
            case NetworkServiceError.networkError, NetworkServiceError.clientError: break
            case let e as NSError:
                if e.domain == NSURLErrorDomain {
                    break
                } else {
                    fallthrough
                }
            default:
                let userInfo: [String: Any] = [NSLocalizedDescriptionKey: "Deployment error",
                                               NSUnderlyingErrorKey: error]
                let loggedError = NSError(domain: "DeploymentDomainService", code: -2, userInfo: userInfo)
                DomainRegistry.logger.error("Error during deployment operation", error: loggedError)
                wallet.cancel()
            }
        }
    }

    /// Repeats a closure indefinitely with a delay between repetitions until the repeater is explicitly stopped.
    /// Before each repetition checks that wallet is not yet created. Otherwise it will force-finalize wallet deployment.
    func `repeat`(for wallet: Wallet, delay: TimeInterval, closure checkShouldStop: @escaping (Wallet) throws -> Bool) throws {
        let repeater = Repeater(delay: delay) { [unowned self] repeater in
            if self.isWalletAlreadyCreated(wallet.address) {
                self.forceFinalizeDeployment(wallet)
                return
            }
            if try checkShouldStop(wallet) {
                self.repeaters.stop(repeater, wallet: wallet.id)
            }
        }
        repeaters.add(repeater, wallet: wallet.id)
        try repeater.start()
    }

    private func isWalletAlreadyCreated(_ address: Address) -> Bool {
        let blockOrNil = try? DomainRegistry.transactionRelayService.safeCreationTransactionBlock(address: address)
        return blockOrNil != nil
    }

    private func forceFinalizeDeployment(_ wallet: Wallet) {
        repeaters.stopAll(for: wallet.id)
        wallet.state = wallet.finalizingDeploymentState
        wallet.proceed()
    }

    private func updateBalance(for wallet: Wallet) throws -> TokenInt {
        let token = wallet.feePaymentTokenAddress ?? Token.Ether.address
        let balance = try self.balance(of: wallet.address, for: token)
        let accountID = AccountID(tokenID: TokenID(token.value), walletID: wallet.id)
        guard let account = DomainRegistry.accountRepository.find(id: accountID) else { return 0 }
        account.update(newAmount: balance)
        DomainRegistry.accountRepository.save(account)
        return balance
    }

    private func balance(of address: Address, for tokenAddress: Address) throws -> TokenInt {
        try retryIfFails(params: config.balance) {
            if tokenAddress == Token.Ether.address {
                return try DomainRegistry.ethereumNodeService.eth_getBalance(account: address)
            } else {
                // NOTE: assuming the ERC20 contract
                let proxy = ERC20TokenContractProxy(tokenAddress)
                return try proxy.balance(of: address)
            }
        }
    }

    private func transactionHash(of wallet: Address) throws -> TransactionHash? {
        try retryIfFails(params: config.deploymentStatus) {
            try DomainRegistry.transactionRelayService.safeCreationTransactionHash(address: wallet)
        }
    }

    private func receipt(of hash: TransactionHash) throws -> TransactionReceipt? {
        try retryIfFails(params: config.transactionStatus) {
            try DomainRegistry.ethereumNodeService.eth_getTransactionReceipt(transaction: hash)
        }
    }

    private func retryIfFails<T>(params: DeploymentDomainServiceConfiguration.Parameters,
                                 action: @escaping () throws -> T) throws -> T {
        try RetryWithIncreasingDelay(maxAttempts: params.retryAttempts, startDelay: params.retryDelay, action).start()
    }

}

public struct DeploymentDomainServiceConfiguration {

    public struct Parameters {

        public var repeatDelay: TimeInterval
        public var retryAttempts: Int
        public var retryDelay: TimeInterval

        public static let standard = Parameters(repeatDelay: 5, retryAttempts: 3, retryDelay: 5)

        public init(repeatDelay: TimeInterval, retryAttempts: Int, retryDelay: TimeInterval) {
            self.repeatDelay = repeatDelay
            self.retryAttempts = retryAttempts
            self.retryDelay = retryDelay
        }

    }

    public var balance: Parameters
    public var deploymentStatus: Parameters
    public var transactionStatus: Parameters

    public static let standard = DeploymentDomainServiceConfiguration(balance: .standard,
                                                                      deploymentStatus: .standard,
                                                                      transactionStatus: .standard)

    public init(balance: Parameters, deploymentStatus: Parameters, transactionStatus: Parameters) {
        self.balance = balance
        self.deploymentStatus = deploymentStatus
        self.transactionStatus = transactionStatus
    }

}

extension DeploymentDomainService {

    // Thread-safe repeaters array operations
    private class Repeaters {

        var repeatersByWallet: [String: [Repeater]] = [:]
        private let queue = DispatchQueue(label: "DeploymentServiceRepeaterManagementQueue")

        func add(_ repeater: Repeater, wallet id: WalletID) {
            let id = id.id
            queue.async { [weak self] in
                guard let `self` = self else { return }
                var repeaters = self.repeatersByWallet[id] ?? []
                repeaters.append(repeater)
                self.repeatersByWallet[id] = repeaters
            }
        }

        func stop(_ repeater: Repeater, wallet id: WalletID) {
            repeater.stop()
            let id = id.id
            queue.async { [weak self] in
                guard let `self` = self else { return }
                var repeaters = self.repeatersByWallet[id] ?? []
                repeaters.removeAll { $0 === repeater }
                self.repeatersByWallet[id] = repeaters
            }
        }

        func stopAll(for id: WalletID) {
            let id = id.id
            queue.async { [weak self] in
                guard let `self` = self else { return }
                let repeaters = self.repeatersByWallet[id] ?? []
                repeaters.forEach { $0.stop() }
                self.repeatersByWallet[id] = []
            }
        }

        func stopAll() {
            queue.async { [weak self] in
                guard let `self` = self else { return }
                for repeaters in self.repeatersByWallet.values {
                    repeaters.forEach { $0.stop() }
                }
                self.repeatersByWallet = [:]
            }
        }

    }

}
