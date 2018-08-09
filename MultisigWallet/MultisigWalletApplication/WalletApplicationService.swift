//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import Common
import BigInt

public class WalletApplicationService: Assertable {

    private var ethereumService: EthereumApplicationService {
        return ApplicationServiceRegistry.ethereumService
    }

    private var notificationService: NotificationDomainService {
        return DomainRegistry.notificationService
    }

    private var tokensService: TokensDomainService {
        return DomainRegistry.tokensService
    }

    public enum WalletState {
        case none
        case newDraft
        case readyToDeploy
        case deploymentStarted
        case addressKnown
        case accountFunded
        case notEnoughFunds
        case deploymentAcceptedByBlockchain
        case readyToUse

        var isBeingCreated: Bool {
            return self == .newDraft || self == .readyToDeploy || isPendingDeployment
        }

        var isPendingDeployment: Bool {
            return WalletState.pendingCreationStates.contains(self)
        }

        var isValidForAccountUpdate: Bool {
            return WalletState.validAccountUpdateStates.contains(self)
        }

        var isReadyToUse: Bool {
            return self == .readyToUse
        }

        private static let pendingCreationStates: [WalletState] = [
            .deploymentStarted,
            .addressKnown,
            .accountFunded,
            .notEnoughFunds,
            .deploymentAcceptedByBlockchain
        ]

        private static let validAccountUpdateStates: [WalletState] = [
            .deploymentStarted,
            .addressKnown,
            .notEnoughFunds
        ]
    }

    public enum OwnerType {
        case thisDevice
        case browserExtension
        case paperWallet

        static let all: [OwnerType] = [.thisDevice, .browserExtension, .paperWallet]

        var kind: String {
            switch self {
            case .thisDevice: return "device"
            case .browserExtension: return "extesnion"
            case .paperWallet: return "paperWallet"
            }
        }
    }

    public enum Error: String, Swift.Error, Hashable {
        case oneOrMoreOwnersAreMissing
        case invalidWalletState
        case missingWalletAddress
        case creationTransactionHashNotFound
        case networkError
        case clientError
        case serverError
        case validationFailed
        case exceededExpirationDate
        case unknownError
        case walletCreationFailed

        public var isNetworkError: Bool {
            return self == .networkError || self == .clientError || self == .clientError
        }
    }

    public static let requiredConfirmationCount: Int = 2

    public var selectedWalletState: WalletState {
        guard let wallet = findSelectedWallet() else { return .none }
        switch wallet.status {
        case .newDraft:
            return .newDraft
        case .readyToDeploy:
            return .readyToDeploy
        case .deploymentStarted:
            return .deploymentStarted
        case .addressKnown:
            let account = findAccount("ETH")!
            if account.balance == 0 {
                return .addressKnown
            } else if account.balance < account.minimumDeploymentTransactionAmount {
                return .notEnoughFunds
            } else {
                return .accountFunded
            }
        case .deploymentAcceptedByBlockchain:
            return .deploymentAcceptedByBlockchain
        case .readyToUse:
            return .readyToUse
        }
    }

    public var hasReadyToUseWallet: Bool {
        return selectedWalletState.isReadyToUse
    }

    public var hasPendingWalletCreation: Bool {
        return selectedWalletState.isPendingDeployment
    }

    public var isSafeCreationInProgress: Bool {
        return selectedWalletState.isBeingCreated
    }

    public var canChangeAccount: Bool {
        return selectedWalletState.isValidForAccountUpdate
    }

    public var selectedWalletAddress: String? {
        return findSelectedWallet()?.address?.value
    }

    public var minimumDeploymentAmount: BigInt? {
        return findAccount("ETH")?.minimumDeploymentTransactionAmount
    }

    private var statusUpdateHandlers = [String: () -> Void]()
    private var errorHandler: ((Swift.Error) -> Void)?

    public init() {}

    // MARK: - Wallet

    public func createNewDraftWallet() {
        notifyWalletStateChangesAfter {
            let portfolio = fetchOrCreatePortfolio()
            let address = ethereumService.generateExternallyOwnedAccount().address
            let owner = Wallet.createOwner(address: address)
            let wallet = Wallet(id: DomainRegistry.walletRepository.nextID(),
                                owner: owner,
                                kind: OwnerType.thisDevice.kind)
            let account = Account(id: AccountID(token: "ETH"), walletID: wallet.id, balance: 0, minimumAmount: 0)
            portfolio.addWallet(wallet.id)
            DomainRegistry.walletRepository.save(wallet)
            DomainRegistry.portfolioRepository.save(portfolio)
            DomainRegistry.accountRepository.save(account)
        }
    }

    private func fetchOrCreatePortfolio() -> Portfolio {
        if let result = DomainRegistry.portfolioRepository.portfolio() {
            return result
        } else {
            return Portfolio(id: DomainRegistry.portfolioRepository.nextID())
        }
    }

    public func startDeployment() throws {
        do {
            if selectedWalletState == .readyToDeploy {
                doStartDeployment()
            }
            if selectedWalletState == .deploymentStarted {
                let data = try requestWalletCreation()
                assignAddress(data.safe)
                updateMinimumFunding(account: "ETH", amount: data.payment)
            }
            if selectedWalletState == .notEnoughFunds || selectedWalletState == .addressKnown {
                try startObservingWalletBalance()
            } else if selectedWalletState == .accountFunded {
                try createWalletInBlockchain()
            } else if selectedWalletState == .deploymentAcceptedByBlockchain {
                try waitForPendingTransaction()
            } else {
                throw Error.invalidWalletState
            }
        } catch let error {
            errorHandler?(error)
            abortDeploymentIfNeeded(by: error)
            throw error
        }
    }

    private func abortDeploymentIfNeeded(by error: Swift.Error) {
        if let walletError = error as? WalletApplicationService.Error, walletError.isNetworkError {
            return
        } else if let ethereumError = error as? EthereumApplicationService.Error, ethereumError.isNetworkError {
            return
        } else if (error as NSError).domain == NSURLErrorDomain {
            return
        }
        abortDeployment()
    }

    private func requestWalletCreation() throws -> SafeCreationTransactionData {
        let owners: [Address] = OwnerType.all.compactMap { Address(ownerAddress(of: $0)!) }
        try assertEqual(owners.count, OwnerType.all.count, Error.oneOrMoreOwnersAreMissing)
        let confirmationCount = WalletApplicationService.requiredConfirmationCount
        return try ethereumService.createSafeCreationTransaction(owners: owners, confirmationCount: confirmationCount)
    }

    private func doStartDeployment() {
        mutateSelectedWallet { wallet in
            wallet.startDeployment()
        }
    }

    private func assignAddress(_ address: String) {
        mutateSelectedWallet { wallet in
            wallet.changeAddress(Address(address))
        }
    }

    private func startObservingWalletBalance() throws {
        let address = findSelectedWallet()!.address!
        try ethereumService.observeChangesInBalance(address: address.value, every: 2) { [weak self] newBalance in
            guard let `self` = self else { return RepeatingShouldStop.yes }
            return self.didUpdateBalance(account: address.value, newBalance: newBalance)
        }
    }

    private func didUpdateBalance(account: String, newBalance: BigInt) -> Bool {
        do {
            guard [WalletState.addressKnown, WalletState.notEnoughFunds, WalletState.accountFunded]
                .contains(selectedWalletState) else {
                return RepeatingShouldStop.yes
            }
            update(account: "ETH", newBalance: newBalance)
            if selectedWalletState == .accountFunded {
                try createWalletInBlockchain()
                return RepeatingShouldStop.yes
            }
            return RepeatingShouldStop.no
        } catch let error {
            errorHandler?(error)
            abortDeploymentIfNeeded(by: error)
            return RepeatingShouldStop.yes
        }
    }

    private func createWalletInBlockchain() throws {
        let address = findSelectedWallet()!.address!
        try ethereumService.startSafeCreation(address: address)
        guard selectedWalletState == .accountFunded else { return }
        markDeploymentAcceptedByBlockchain()
        try waitForPendingTransaction()
    }

    private func waitForPendingTransaction() throws {
        let wallet = findSelectedWallet()!
        var hash = wallet.creationTransactionHash
        if hash == nil {
            let address = wallet.address!
            hash = try ethereumService.waitForCreationTransaction(address: address)
            storeTransactionHash(hash: hash!)
        }
        let isSuccess = try ethereumService.waitForPendingTransaction(hash: hash!)
        guard selectedWalletState == .deploymentAcceptedByBlockchain else { return }
        if isSuccess {
            try notifySafeCreated()
        }
        didFinishDeployment(success: isSuccess)
    }

    private func storeTransactionHash(hash: String) {
        mutateSelectedWallet { wallet in
            wallet.assignCreationTransaction(hash: hash)
        }
    }

    private func didFinishDeployment(success: Bool) {
        if success {
            removePaperWallet()
            finishDeployment()
        } else {
            let wallet = findSelectedWallet()!
            let txHash = wallet.creationTransactionHash!
            let address = wallet.address!
            let message = "Transaction '\(txHash)' failed for safe creation at address '\(address)'. Crashing."
            ApplicationServiceRegistry.logger.fatal(message, error: Error.walletCreationFailed)
            exit(EXIT_FAILURE)
        }
    }

    private func notifySafeCreated() throws {
        try notifyBrowserExtension(message: notificationService.safeCreatedMessage(at: selectedWalletAddress!))
    }

    private func notifyBrowserExtension(message: String) throws {
        let sender = ownerAddress(of: .thisDevice)!
        let recipient = ownerAddress(of: .browserExtension)!
        let signedAddress = ethereumService.sign(message: "GNO" + message, by: sender)!
        let request = SendNotificationRequest(message: message, to: recipient, from: signedAddress)
        try handleNotificationServiceError {
            try notificationService.send(notificationRequest: request)
        }
    }

    private func fetchBalance() throws {
        let address = findSelectedWallet()!.address!.value
        let newBalance = try ethereumService.balance(address: address)
        update(account: "ETH", newBalance: newBalance)
    }

    private func removePaperWallet() {
        let paperWallet = ownerAddress(of: .paperWallet)!
        ethereumService.removeExternallyOwnedAccount(address: paperWallet)
    }

    private func markReadyToDeploy() {
        mutateSelectedWallet { wallet in
            wallet.markReadyToDeploy()
        }
    }

    public func markDeploymentAcceptedByBlockchain() {
        mutateSelectedWallet { wallet in
            wallet.markDeploymentAcceptedByBlockchain()
        }
    }

    public func abortDeployment() {
        mutateSelectedWallet { wallet in
            wallet.abortDeployment()
        }
    }

    public func finishDeployment() {
        mutateSelectedWallet { wallet in
            wallet.finishDeployment()
        }
    }

    private func mutateSelectedWallet(_ closure: (Wallet) -> Void) {
        notifyWalletStateChangesAfter {
            let wallet = findSelectedWallet()!
            closure(wallet)
            DomainRegistry.walletRepository.save(wallet)
        }
    }

    private func findSelectedWallet() -> Wallet? {
        guard let portfolio = DomainRegistry.portfolioRepository.portfolio(),
            let walletID = portfolio.selectedWallet,
            let wallet = DomainRegistry.walletRepository.findByID(walletID) else {
            return nil
        }
        return wallet
    }

    private func notifyWalletStateChangesAfter(_ closure: () -> Void) {
        let startState = selectedWalletState
        closure()
        let endState = selectedWalletState
        if startState != endState {
            notifyStatusUpdate()
        }
    }

    // MARK: - Owners

    public func isOwnerExists(_ type: OwnerType) -> Bool {
        guard let wallet = findSelectedWallet(), wallet.owner(kind: type.kind) != nil else { return false }
        return true
    }

    public func addOwner(address: String, type: OwnerType) {
        mutateSelectedWallet { wallet in
            let owner = Wallet.createOwner(address: address)
            if wallet.owner(kind: type.kind) != nil {
                wallet.replaceOwner(with: owner, kind: type.kind)
            } else {
                wallet.addOwner(owner, kind: type.kind)
            }
            if wallet.status == .newDraft {
                let enoughOwnersExist = OwnerType.all.reduce(true) { isEnough, type in
                    isEnough && wallet.owner(kind: type.kind) != nil
                }
                if enoughOwnersExist {
                    wallet.markReadyToDeploy()
                }
            }
        }
    }

    public func addBrowserExtensionOwner(address: String, browserExtensionCode rawCode: String) throws {
        let deviceOwnerAddress = ownerAddress(of: .thisDevice)!
        let signature = ethereumService.sign(message: "GNO" + address, by: deviceOwnerAddress)!
        guard let code = browserExtensionCode(from: rawCode) else {
            throw Error.validationFailed
        }
        try pair(code, signature, deviceOwnerAddress)
        addOwner(address: address, type: .browserExtension)
    }

    private func pair(_ browserExtension: BrowserExtensionCode,
                      _ signature: EthSignature,
                      _ deviceOwnerAddress: String) throws {
        try handleNotificationServiceError {
            try notificationService.pair(pairingRequest: PairingRequest(temporaryAuthorization: browserExtension,
                                                                        signature: signature,
                                                                        deviceOwnerAddress: deviceOwnerAddress))
        }
    }

    @discardableResult
    private func handleNotificationServiceError<T>(_ block: () throws -> T) throws -> T {
        do {
            return try block()
        } catch NotificationDomainServiceError.validationFailed {
            throw Error.validationFailed
        } catch let JSONHTTPClient.Error.networkRequestFailed(request, response, data) {
            logNetworkError(request, response, data)
            if let data = data, let dataStr = String(data: data, encoding: .utf8),
                dataStr.range(of: "Exceeded expiration date") != nil {
                throw Error.exceededExpirationDate
            } else if let response = response as? HTTPURLResponse {
                throw (400..<500).contains(response.statusCode) ? Error.clientError : Error.serverError
            } else {
                throw Error.networkError
            }
        }
    }
    @discardableResult
    private func handleRelayServiceErrors<T>(_ block: () throws -> T) throws -> T {
        do {
            return try block()
        } catch let error as NetworkServiceError {
            throw self.error(from: error)
        } catch let JSONHTTPClient.Error.networkRequestFailed(request, response, data) {
            logNetworkError(request, response, data)
            throw self.error(from: response)
        }
    }

    /// TODO: remove in release
    private func logNetworkError(_ request: URLRequest, _ response: URLResponse?, _ data: Data?) {
        var userInfo = [String: Any]()
        userInfo["request"] = request
        if let response = response {
            userInfo["response"] = response
        }
        if let data = data, let string = String(data: data, encoding: .utf8) {
            userInfo["data"] = string
        }
        let nsError = NSError(domain: "pm.gnosis.safe", code: 1, userInfo: userInfo)
        ApplicationServiceRegistry.logger.error("Request failed", error: nsError)
    }

    private func error(from response: URLResponse?) -> Error {
        if let response = response as? HTTPURLResponse {
            if (400..<500).contains(response.statusCode) {
                return .clientError
            } else {
                return .serverError
            }
        }
        return .networkError
    }

    private func error(from other: NetworkServiceError) -> Error {
        switch other {
        case .clientError:
            return .clientError
        case .networkError:
            return .networkError
        case .serverError:
            return .serverError
        }
    }

    internal func browserExtensionCode(from json: String) -> BrowserExtensionCode? {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter.networkDateFormatter
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        guard let jsonData = json.data(using: .utf8),
            var code = try? decoder.decode(BrowserExtensionCode.self, from: jsonData) else {
                return nil
        }
        code.extensionAddress = ethereumService.address(browserExtensionCode: json)
        return code
    }

    public func ownerAddress(of type: OwnerType) -> String? {
        return address(of: type)?.value
    }

    private func address(of type: OwnerType) -> Address? {
        guard let wallet = findSelectedWallet(), let owner = wallet.owner(kind: type.kind) else { return nil }
        return owner.address
    }

    // MARK: - Accounts

    public func accountBalance(token: String) -> BigInt? {
       return findAccount(token)?.balance
    }

    private func updateMinimumFunding(account token: String, amount: BigInt) {
        assertCanChangeAccount()
        mutateAccount(token: token) { account in
            account.updateMinimumTransactionAmount(amount)
        }
    }

    private func assertCanChangeAccount() {
        try! assertTrue(selectedWalletState.isValidForAccountUpdate, Error.invalidWalletState)
    }

    public func update(account token: String, newBalance: BigInt) {
        assertCanChangeAccount()
        mutateAccount(token: token) { account in
            account.update(newAmount: newBalance)
        }
    }

    private func mutateAccount(token: String, closure: (Account) -> Void) {
        notifyWalletStateChangesAfter {
            let account = findAccount(token)!
            closure(account)
            DomainRegistry.accountRepository.save(account)
        }
    }

    public func updateTransaction(_ id: String, amount: BigInt, recipient: String) {
        let transaction = DomainRegistry.transactionRepository.findByID(TransactionID(id))!
        transaction.change(amount: .ether(amount))
            .change(recipient: Address(recipient))
        DomainRegistry.transactionRepository.save(transaction)
    }

    public func estimateTransferFee(amount: BigInt, address: String?) -> BigInt? {
        let placeholderAddress = Address(ownerAddress(of: .thisDevice)!)
        let formattedAddress = address == nil || address!.isEmpty ? placeholderAddress :
            DomainRegistry.encryptionService.address(from: address!)
        guard let recipient = formattedAddress, !recipient.isZero else { return nil }
        let request = EstimateTransactionRequest(safe: Address(selectedWalletAddress!),
                                                 to: recipient,
                                                 value: String(amount),
                                                 data: nil,
                                                 operation: .call)
        guard let response = try? DomainRegistry.transactionRelayService.estimateTransaction(request: request) else {
            return nil
        }
        return (BigInt(response.dataGas) + BigInt(response.safeTxGas)) * BigInt(response.gasPrice)
    }

    public func transactionData(_ id: String) -> TransactionData? {
        guard let tx = DomainRegistry.transactionRepository.findByID(TransactionID(id)) else {
            return nil
        }
        return TransactionData(id: tx.id.id,
                               sender: tx.sender?.value ?? "",
                               recipient: tx.recipient?.value ?? "",
                               amount: tx.amount?.amount ?? 0,
                               token: "ETH",
                               fee: tx.fee?.amount ?? 0,
                               status: status(of: tx))
    }

    private func status(of tx: Transaction) -> TransactionData.Status {
        let defaultStatus = TransactionData.Status.waitingForConfirmation
        switch tx.status {
        case .signing:
            return tx.signatures.count == 1
                && tx.isSignedBy(address(of: .browserExtension)!) ? .readyToSubmit : defaultStatus
        case .rejected:
            return .rejected
        case .pending:
            return .pending
        case .failed:
            return .failed
        case .success:
            return .success
        case .discarded:
            return .discarded
        case .draft:
            return defaultStatus
        }
    }

    public func createNewDraftTransaction() -> String {
        let repository = DomainRegistry.transactionRepository
        let transaction = Transaction(id: repository.nextID(),
                                      type: .transfer,
                                      walletID: findSelectedWallet()!.id,
                                      accountID: AccountID(token: "ETH"))
        transaction.change(sender: findSelectedWallet()!.address!)
        repository.save(transaction)
        return transaction.id.id
    }

    public func requestTransactionConfirmation(_ id: String) throws -> TransactionData {
        let tx = DomainRegistry.transactionRepository.findByID(TransactionID(id))!
        if tx.status == .draft {
            let estimation = try estimateTransaction(tx)
            let fee = TokenInt(estimation.gas + estimation.dataGas) * estimation.gasPrice.amount
            tx.change(feeEstimate: estimation)
                .change(fee: TokenAmount(amount: fee, token: estimation.gasPrice.token))
            let nonce = try ethereumService.nonce(contractAddress: tx.sender!)
            tx.change(nonce: String(nonce))
                .change(operation: .call)
                .change(hash: ethereumService.hash(of: tx))
                .change(status: .signing)
            DomainRegistry.transactionRepository.save(tx)
        }
        try notifyBrowserExtension(message: notificationService.requestConfirmationMessage(for: tx, hash: tx.hash!))
        return transactionData(id)!
    }

    private func estimateTransaction(_ tx: Transaction) throws -> TransactionFeeEstimate {
        let recipient = DomainRegistry.encryptionService.address(from: tx.recipient!.value)!
        let request = EstimateTransactionRequest(safe: tx.sender!,
                                                 to: recipient,
                                                 value: String(tx.amount!.amount),
                                                 data: nil,
                                                 operation: .call)

        let estimationResponse = try handleRelayServiceErrors {
            try DomainRegistry.transactionRelayService.estimateTransaction(request: request)
        }
        let gasToken = Token(code: "ETH", decimals: 18, address: Address(estimationResponse.gasToken))
        let feeEstimate = TransactionFeeEstimate(gas: estimationResponse.safeTxGas,
                                                 dataGas: estimationResponse.dataGas,
                                                 gasPrice: TokenAmount(amount: TokenInt(estimationResponse.gasPrice),
                                                                       token: gasToken))
        return feeEstimate
    }

    public enum TransactionError: Swift.Error {
        case unsignedTransaction
    }

    public func submitTransaction(_ id: String) throws -> TransactionData {
        let tx = DomainRegistry.transactionRepository.findByID(TransactionID(id))!
        signTransaction(tx)
        let hash = try submitTransaction(tx)
        tx.set(hash: hash).change(status: .pending)
        DomainRegistry.transactionRepository.save(tx)
        try? notifyBrowserExtension(message: notificationService.transactionSentMessage(for: tx))
        return transactionData(id)!
    }

    private func signTransaction(_ tx: Transaction) {
        try! assertTrue(tx.isSignedBy(address(of: .browserExtension)!), TransactionError.unsignedTransaction)
        let myAddress = address(of: .thisDevice)!
        if !tx.isSignedBy(myAddress) {
            let pk = DomainRegistry.externallyOwnedAccountRepository.find(by: myAddress)!.privateKey
            let signatureData = DomainRegistry.encryptionService.sign(transaction: tx, privateKey: pk)
            tx.add(signature: Signature(data: signatureData, address: myAddress))
        }
    }

    private func submitTransaction(_ tx: Transaction) throws -> TransactionHash {
        let signatures = tx.signatures.sorted { $0.address.value < $1.address.value }.map {
            DomainRegistry.encryptionService.ethSignature(from: $0)
        }
        return try handleRelayServiceErrors {
            let request = SubmitTransactionRequest(transaction: tx, signatures: signatures)
            let response = try DomainRegistry.transactionRelayService.submitTransaction(request: request)
            return TransactionHash(response.transactionHash)
        }
    }

    private func findAccount(_ token: String) -> Account? {
        guard let wallet = findSelectedWallet(),
            let account = DomainRegistry.accountRepository.find(id: AccountID(token: token), walletID: wallet.id) else {
            return nil
        }
        return account
    }

    // MARK: - Wallet status update subscribing

    public func subscribe(_ update: @escaping () -> Void) -> String {
        let key = UUID().uuidString
        statusUpdateHandlers[key] = update
        return key
    }

    public func unsubscribe(subscription: String) {
        statusUpdateHandlers.removeValue(forKey: subscription)
    }

    public func setErrorHandler(_ handler: ((Swift.Error) -> Void)?) {
        errorHandler = handler
    }

    private func notifyStatusUpdate() {
        statusUpdateHandlers.values.forEach { $0() }
    }

    // MARK: - Notifications

    public func auth() throws {
        precondition(!Thread.isMainThread)
        guard let pushToken = tokensService.pushToken() else { return }
        let deviceOwnerAddress = ownerAddress(of: .thisDevice)!
        let signature = ethereumService.sign(message: "GNO" + pushToken, by: deviceOwnerAddress)!
        try handleNotificationServiceError {
            try notificationService.auth(request: AuthRequest(pushToken: pushToken,
                                                              signature: signature,
                                                              deviceOwnerAddress: deviceOwnerAddress))
        }
    }

    // MARK: - Message Handling

    public func receive(message userInfo: [AnyHashable: Any]) -> String? {
        guard let message = Message.create(userInfo: userInfo) else { return nil }
        if let confirmation = message as? TransactionConfirmedMessage {
            return handle(message: confirmation)
        } else if let rejection = message as? TransactionRejectedMessage {
            return handle(message: rejection)
        }
        return nil
    }

    func handle(message: TransactionConfirmedMessage) -> String? {
        guard let transaction = self.transaction(from: message, hash: message.hash) else { return nil }
        let extensionAddress = address(of: .browserExtension)!
        let encryptionService = DomainRegistry.encryptionService
        transaction.add(signature: Signature(data: encryptionService.data(from: message.signature),
                                             address: extensionAddress))
        DomainRegistry.transactionRepository.save(transaction)
        return transaction.id.id
    }

    private func transaction(from message: TransactionDecisionMessage, hash: Data) -> Transaction? {
        guard let transaction = DomainRegistry.transactionRepository.findByHash(message.hash),
            let sender = ethereumService.address(hash: hash, signature: message.signature),
            let extensionAddress = ownerAddress(of: .browserExtension),
            sender.value.lowercased() == extensionAddress.lowercased() else {
                return nil
        }
        return transaction
    }

    func handle(message: TransactionRejectedMessage) -> String? {
        let payload = "GNO" + "0x" + message.hash.toHexString() + message.type
        let hash = DomainRegistry.encryptionService.hash(payload.data(using: .utf8)!)
        guard let transaction = self.transaction(from: message, hash: hash) else { return nil }
        transaction.change(status: .rejected)
        DomainRegistry.transactionRepository.save(transaction)
        return transaction.id.id
    }

}
