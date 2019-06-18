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

    // Thread-safe repeaters array operations
    private class Repeaters {

        var repeaters: [Repeater] = []
        private let queue = DispatchQueue(label: "DeploymentServiceRepeaterManagementQueue")

        func add(_ repeater: Repeater) {
            queue.async { [weak self] in
                guard let `self` = self else { return }
                self.repeaters.append(repeater)
            }
        }

        func stop(_ repeater: Repeater) {
            repeater.stop()
            queue.async { [weak self] in
                guard let `self` = self else { return }
                self.repeaters.removeAll { $0 === repeater }
            }
        }

        func stopAll() {
            queue.async { [weak self] in
                guard let `self` = self else { return }
                self.repeaters.forEach { $0.stop() }
                self.repeaters = []
            }
        }

    }

    public init(_ config: DeploymentDomainServiceConfiguration = .standard) {
        self.config = config
    }

    public func start() {
        DomainRegistry.eventPublisher.unsubscribe(self)
        DomainRegistry.eventPublisher.subscribe(self, deploymentStarted)
        DomainRegistry.eventPublisher.subscribe(self, waitingForFirstDeposit)
        DomainRegistry.eventPublisher.subscribe(self, waitingForRemainingAmount)
        DomainRegistry.eventPublisher.subscribe(self, walletFunded)
        DomainRegistry.eventPublisher.subscribe(self, creationStarted)
        DomainRegistry.eventPublisher.subscribe(self, walletCreated)
        DomainRegistry.eventPublisher.subscribe(self, creationFailed)
        DomainRegistry.eventPublisher.subscribe(self, deploymentAborted)

        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        wallet.resume()
    }

    public func createNewDraftWallet() {
        let portfolio = WalletDomainService.fetchOrCreatePortfolio()
        let address = WalletDomainService.newOwner()
        let wallet = Wallet(id: DomainRegistry.walletRepository.nextID(), owner: address)
        let account = Account(tokenID: Token.Ether.id, walletID: wallet.id)
        portfolio.addWallet(wallet.id)
        DomainRegistry.walletRepository.save(wallet)
        DomainRegistry.portfolioRepository.save(portfolio)
        DomainRegistry.accountRepository.save(account)
    }

    public func prepareForCreation() {
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        wallet.reset()
        wallet.prepareForCreation()
        DomainRegistry.walletRepository.save(wallet)
        WalletDomainService.recreateOwners()
    }

    func deploymentStarted(_ event: DeploymentStarted) {
        handleError { wallet in
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
            wallet.proceed()
        }
    }

    func deploymentAborted(_ event: DeploymentAborted) {
        repeaters.stopAll()
    }

    func waitingForFirstDeposit(_ event: StartedWaitingForFirstDeposit) {
        handleError { wallet in
            try waitForFirstDeposit(wallet)
        }
    }

    private func waitForFirstDeposit(_ wallet: Wallet) throws {
        try self.repeat(delay: config.balance.repeatDelay) { [unowned self] repeater in
            let balance = try self.updateBalance(for: wallet)
            guard balance > 0 else { return }
            self.repeaters.stop(repeater)
            wallet.proceed()
        }
    }

    func waitingForRemainingAmount(_ event: StartedWaitingForRemainingFeeAmount) {
        handleError { wallet in
            try waitForFunding(wallet)
        }
    }

    private func waitForFunding(_ wallet: Wallet) throws {
        try self.repeat(delay: config.balance.repeatDelay) { [unowned self] repeater in
            let balance = try self.updateBalance(for: wallet)
            guard balance >= wallet.minimumDeploymentTransactionAmount! else { return }
            self.repeaters.stop(repeater)
            wallet.proceed()
        }
    }

    private func updateBalance(for wallet: Wallet) throws -> TokenInt {
        let token = wallet.feePaymentTokenAddress ?? Token.Ether.address
        let balance = try self.balance(of: wallet.address!, for: token)
        let accountID = AccountID(tokenID: TokenID(token.value), walletID: wallet.id)
        let account = DomainRegistry.accountRepository.find(id: accountID)!
        account.update(newAmount: balance)
        DomainRegistry.accountRepository.save(account)
        return balance
    }

    private func `repeat`(delay: TimeInterval, closure: @escaping (Repeater) throws -> Void) throws {
        let repeater = Repeater(delay: delay) { [unowned self] repeater in
            let wallet = DomainRegistry.walletRepository.selectedWallet()!
            if self.walletAlreadyCreated(wallet) {
                self.forceFinalizeDeployment(wallet)
                return
            }
            try closure(repeater)
        }
        repeaters.add(repeater)
        try repeater.start()
    }

    private func walletAlreadyCreated(_ wallet: Wallet) -> Bool {
        do {
            _ = try DomainRegistry.transactionRelayService.safeInfo(address: wallet.address!)
            return true
        } catch {
            return false
        }
    }

    private func forceFinalizeDeployment(_ wallet: Wallet) {
        repeaters.stopAll()
        wallet.state = wallet.finalizingDeploymentState
        wallet.proceed()
    }

    func walletFunded(_ event: DeploymentFunded) {
        handleError { wallet in
            try DomainRegistry.transactionRelayService.startSafeCreation(address: wallet.address!)
            wallet.proceed()
        }
    }

    func creationStarted(_ event: CreationStarted) {
        handleError { wallet in
            synchronise()
            try waitForCreationTransactionHash(wallet)
            guard !wallet.isReadyToUse else { return }
            try waitForCreationTransactionCompletion(wallet)
        }
    }

    private func synchronise() {
        DispatchQueue.global().async {
            DomainRegistry.syncService.syncOnce()
        }
    }

    private func waitForCreationTransactionHash(_ wallet: Wallet) throws {
        guard wallet.creationTransactionHash == nil else {
            DomainRegistry.eventPublisher.publish(WalletTransactionHashIsKnown())
            return
        }
        try self.repeat(delay: config.deploymentStatus.repeatDelay) { [unowned self] repeater in
            guard let hash = try self.transactionHash(of: wallet.address!) else { return }
            wallet.assignCreationTransaction(hash: hash.value)
            self.repeaters.stop(repeater)
            DomainRegistry.walletRepository.save(wallet)
            DomainRegistry.eventPublisher.publish(WalletTransactionHashIsKnown())
        }
    }

    private func waitForCreationTransactionCompletion(_ wallet: Wallet) throws {
        try self.repeat(delay: config.transactionStatus.repeatDelay) { [unowned self] repeater in
            guard let receipt = try self.receipt(of: TransactionHash(wallet.creationTransactionHash!)) else { return }
            self.repeaters.stop(repeater)
            if receipt.status == .success {
                wallet.proceed()
            } else {
                let userInfo: [String: Any] = [NSLocalizedDescriptionKey: "Creation transaction failed",
                                               "walletCreationTransactionHash": wallet.creationTransactionHash!,
                                               "walletInfo": wallet.dump()]
                let error = NSError(domain: "DeploymentDomainService", code: -1, userInfo: userInfo)
                DomainRegistry.logger.error("Wallet creation transaction failed", error: error)
                wallet.cancel()
            }
        }
    }

    func walletCreated(_ event: WalletCreated) {
        handleError { wallet in
            try notifyDidCreate(wallet)
            DomainRegistry.externallyOwnedAccountRepository.remove(address:
                wallet.owner(role: .paperWallet)!.address)
            DomainRegistry.externallyOwnedAccountRepository.remove(address:
                wallet.owner(role: .paperWalletDerived)!.address)
        }
    }

    private func notifyDidCreate(_ wallet: Wallet) throws {
        try DomainRegistry.communicationService.notifyWalletCreated(walletID: wallet.id)
    }

    func creationFailed(_ event: WalletCreationFailed) {
        DomainRegistry.system.exit(EXIT_FAILURE)
    }

    private func handleError(_ closure: (Wallet) throws -> Void) {
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
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
                                               NSUnderlyingErrorKey: error,
                                               "walletInfo": wallet.dump()]
                let loggedError = NSError(domain: "DeploymentDomainService", code: -2, userInfo: userInfo)
                DomainRegistry.logger.error("Error during deployment operation", error: loggedError)
                wallet.cancel()
            }
        }
    }

    private func balance(of address: Address, for tokenAddress: Address) throws -> TokenInt {
        return try RetryWithIncreasingDelay(maxAttempts: config.balance.retryAttempts,
                                            startDelay: config.balance.retryDelay) {
                if tokenAddress == Token.Ether.address {
                    return try DomainRegistry.ethereumNodeService.eth_getBalance(account: address)
                } else {
                    // NOTE: assuming the ERC20 contract
                    let proxy = ERC20TokenContractProxy(tokenAddress)
                    return try proxy.balance(of: address)
                }
            }.start()
    }

    private func transactionHash(of wallet: Address) throws -> TransactionHash? {
        return try RetryWithIncreasingDelay(maxAttempts: config.deploymentStatus.retryAttempts,
                                            startDelay: config.deploymentStatus.retryDelay) {
                try DomainRegistry.transactionRelayService.safeCreationTransactionHash(address: wallet)
            }.start()
    }

    private func receipt(of hash: TransactionHash) throws -> TransactionReceipt? {
        return try RetryWithIncreasingDelay(maxAttempts: config.transactionStatus.retryAttempts,
                                            startDelay: config.transactionStatus.retryDelay) {
                try DomainRegistry.ethereumNodeService.eth_getTransactionReceipt(transaction: hash)
            }.start()
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
