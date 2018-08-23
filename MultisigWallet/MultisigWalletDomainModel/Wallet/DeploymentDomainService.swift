//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Implements business logic required to deploy a multisignature wallet. Deployment is a multi-step process,
/// with every step could take significant amount of time. Nevertheless, the service itself is stateless and
/// all changes in the deployment process are recorded in other domain objects and stored in repositories.
public class DeploymentDomainService {

    private let config: DeploymentDomainServiceConfiguration
    internal var responseValidator = SafeCreationResponseValidator()

    public init(_ config: DeploymentDomainServiceConfiguration = .standard) {
        self.config = config
    }

    public func start() {
        DomainRegistry.eventPublisher.subscribe(deploymentStarted)
        DomainRegistry.eventPublisher.subscribe(walletConfigured)
        DomainRegistry.eventPublisher.subscribe(walletFunded)
        DomainRegistry.eventPublisher.subscribe(creationStarted)
        DomainRegistry.eventPublisher.subscribe(walletCreated)
        DomainRegistry.eventPublisher.subscribe(creationFailed)
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        wallet.resume()
    }

    func deploymentStarted(_ event: DeploymentStarted) {
        handleError { wallet in
            let s = DomainRegistry.encryptionService.ecdsaRandomS()
            let request = SafeCreationTransactionRequest(owners: wallet.allOwners().map { $0.address },
                                                         confirmationCount: wallet.confirmationCount,
                                                         ecdsaRandomS: s)
            let response = try DomainRegistry.transactionRelayService.createSafeCreationTransaction(request: request)
            try responseValidator.validate(response, request: request)
            wallet.changeAddress(response.walletAddress)
            wallet.updateMinimumTransactionAmount(response.deploymentFee)
            wallet.proceed()
        }
    }

    func walletConfigured(_ event: WalletConfigured) {
        handleError { wallet in
            try waitForFunding(wallet)
        }
    }

    private func waitForFunding(_ wallet: Wallet) throws {
        try Repeater(delay: config.balance.repeatDelay) { [unowned self] repeater in
            let balance = try self.balance(of: wallet.address!)
            let accountID = AccountID(tokenID: Token.Ether.id, walletID: wallet.id)
            let account = DomainRegistry.accountRepository.find(id: accountID, walletID: wallet.id)!
            account.update(newAmount: balance)
            DomainRegistry.accountRepository.save(account)
            guard balance >= wallet.minimumDeploymentTransactionAmount!  else { return }
            repeater.stop()
            wallet.proceed()
        }.start()
    }

    func walletFunded(_ event: DeploymentFunded) {
        handleError { wallet in
            try DomainRegistry.transactionRelayService.startSafeCreation(address: wallet.address!)
            wallet.proceed()
        }
    }

    func creationStarted(_ event: CreationStarted) {
        handleError { wallet in
            try waitForCreationTransactionHash(wallet)
            try waitForCreationTransactionCompletion(wallet)
        }
    }

    private func waitForCreationTransactionHash(_ wallet: Wallet) throws {
        guard wallet.creationTransactionHash == nil else { return }
        try Repeater(delay: config.deploymentStatus.repeatDelay) { [unowned self] repeater in
            guard let hash = try self.transactionHash(of: wallet.address!) else { return }
            wallet.assignCreationTransaction(hash: hash.value)
            repeater.stop()
            DomainRegistry.walletRepository.save(wallet)
            }.start()
    }

    private func waitForCreationTransactionCompletion(_ wallet: Wallet) throws {
        try Repeater(delay: config.transactionStatus.repeatDelay) { [unowned self] repeater in
            guard let receipt = try self.receipt(of: TransactionHash(wallet.creationTransactionHash!)) else { return }
            repeater.stop()
            if receipt.status == .success {
                wallet.proceed()
            } else {
                wallet.cancel()
            }
        }.start()
    }

    func walletCreated(_ event: WalletCreated) {
        handleError { wallet in
            try notifyDidCreate(wallet)
            DomainRegistry.externallyOwnedAccountRepository.remove(address: wallet.owner(role: .paperWallet)!.address)
        }
    }

    private func notifyDidCreate(_ wallet: Wallet) throws {
        let sender = wallet.owner(role: .thisDevice)!.address
        let recipient = wallet.owner(role: .browserExtension)!.address
        let senderEOA = DomainRegistry.externallyOwnedAccountRepository.find(by: sender)!
        let message = DomainRegistry.notificationService.safeCreatedMessage(at: wallet.address!.value)
        let signedAddress = DomainRegistry.encryptionService.sign(message: "GNO" + message,
                                                                  privateKey: senderEOA.privateKey)
        let request = SendNotificationRequest(message: message, to: recipient.value, from: signedAddress)
        try DomainRegistry.notificationService.send(notificationRequest: request)
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
            default: wallet.cancel()
            }

        }
        DomainRegistry.walletRepository.save(wallet)
    }

    private func balance(of address: Address) throws -> TokenInt {
        return try RetryWithIncreasingDelay(maxAttempts: config.balance.retryAttempts,
                                            startDelay: config.balance.retryDelay) { _ in
                try DomainRegistry.ethereumNodeService.eth_getBalance(account: address)
            }.start()
    }

    private func transactionHash(of wallet: Address) throws -> TransactionHash? {
        return try RetryWithIncreasingDelay(maxAttempts: config.deploymentStatus.retryAttempts,
                                            startDelay: config.deploymentStatus.retryDelay) { _ in
                try DomainRegistry.transactionRelayService.safeCreationTransactionHash(address: wallet)
            }.start()
    }

    private func receipt(of hash: TransactionHash) throws -> TransactionReceipt? {
        return try RetryWithIncreasingDelay(maxAttempts: config.transactionStatus.retryAttempts,
                                            startDelay: config.transactionStatus.retryDelay) { _ in
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
