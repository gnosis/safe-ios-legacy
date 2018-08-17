//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Implements business logic required to deploy a multisignature wallet. Deployment is a multi-step process,
/// with every step could take significant amount of time. Nevertheless, the service itself is stateless and
/// all changes in the deployment process are recorded in other domain objects and stored in repositories.
public class DeploymentDomainService {

    private let config: DeploymentDomainServiceConfiguration

    public init(_ config: DeploymentDomainServiceConfiguration = .standard) {
        self.config = config
    }

    public func start() {
        DomainRegistry.eventPublisher.subscribe(deploymentStarted)
        DomainRegistry.eventPublisher.subscribe(walletConfigured)
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        wallet.proceed()
    }

    func deploymentStarted(_ event: DeploymentStarted) {
        handleError { wallet in
            let s = DomainRegistry.encryptionService.ecdsaRandomS()
            let request = SafeCreationTransactionRequest(owners: wallet.allOwners().map { $0.address },
                                                         confirmationCount: wallet.confirmationCount,
                                                         ecdsaRandomS: s)
            let response = try DomainRegistry.transactionRelayService.createSafeCreationTransaction(request: request)
            wallet.changeAddress(response.walletAddress)
            wallet.updateMinimumTransactionAmount(response.deploymentFee)
            wallet.proceed()
        }
    }

    func walletConfigured(_ event: WalletConfigured) {
        handleError { wallet in
            try Repeat(delay: config.balanceRepeatDelay) { [unowned self] repeater in
                let balance = try self.balance(of: wallet.address!)
                let accountID = AccountID(Token.Ether.id.id)
                let account = DomainRegistry.accountRepository.find(id: accountID, walletID: wallet.id)!
                account.update(newAmount: balance)
                DomainRegistry.accountRepository.save(account)
                if balance >= wallet.minimumDeploymentTransactionAmount! {
                    repeater.stop()
                    wallet.proceed()
                }
            }.start()
        }
    }

    private func handleError(_ closure: (Wallet) throws -> Void) {
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        do {
            try closure(wallet)
        } catch let error {
            DomainRegistry.errorStream.post(error)
            wallet.cancel()
        }
        DomainRegistry.walletRepository.save(wallet)
    }

    private func balance(of address: Address) throws -> TokenInt {
        return try Retry(maxAttempts: config.balanceRetryMaxAttempts, delay: config.balanceRetryDelay) { _ in
            try DomainRegistry.ethereumNodeService.eth_getBalance(account: address)
        }.start()
    }

}

public struct DeploymentDomainServiceConfiguration {

    public var balanceRepeatDelay: TimeInterval
    public var balanceRetryMaxAttempts: Int
    public var balanceRetryDelay: TimeInterval

    public static let standard = DeploymentDomainServiceConfiguration(balanceRepeatDelay: 2,
                                                                      balanceRetryMaxAttempts: 10,
                                                                      balanceRetryDelay: 2)

    public init(balanceRepeatDelay: TimeInterval,
                balanceRetryMaxAttempts: Int,
                balanceRetryDelay: TimeInterval) {
        self.balanceRepeatDelay = balanceRepeatDelay
        self.balanceRetryDelay = balanceRetryDelay
        self.balanceRetryMaxAttempts = balanceRetryMaxAttempts
    }

}
