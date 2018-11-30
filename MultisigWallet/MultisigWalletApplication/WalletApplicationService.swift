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

    private var pushTokensService: PushTokensDomainService {
        return DomainRegistry.pushTokensService
    }

    public var hasSelectedWallet: Bool { return selectedWallet != nil }

    public var hasReadyToUseWallet: Bool {
        guard let wallet = selectedWallet else { return false }
        return wallet.state === wallet.readyToUseState
    }

    public var isWalletDeployable: Bool {
        guard let wallet = selectedWallet else { return false }
        return wallet.isDeployable
    }

    public var isSafeCreationInProgress: Bool {
        guard let wallet = selectedWallet else { return false }
        return wallet.state !== wallet.newDraftState && wallet.state !== wallet.readyToUseState
    }

    public var canChangeAccount: Bool {
        return selectedWalletAddress != nil
    }

    public var selectedWalletAddress: String? {
        return selectedWallet?.address?.value
    }

    public var minimumDeploymentAmount: BigInt? {
        return selectedWallet?.minimumDeploymentTransactionAmount
    }

    public let configuration: WalletApplicationServiceConfiguration

    public init(configuration: WalletApplicationServiceConfiguration = .default) {
        self.configuration = configuration
    }

    // MARK: - Wallet

    public func createNewDraftWallet() {
        let portfolio = fetchOrCreatePortfolio()
        let address = ethereumService.generateExternallyOwnedAccount().address
        let wallet = Wallet(id: DomainRegistry.walletRepository.nextID(), owner: Address(address))
        let account = Account(tokenID: Token.Ether.id, walletID: wallet.id)
        portfolio.addWallet(wallet.id)
        DomainRegistry.walletRepository.save(wallet)
        DomainRegistry.portfolioRepository.save(portfolio)
        DomainRegistry.accountRepository.save(account)
    }

    private func fetchOrCreatePortfolio() -> Portfolio {
        if let result = DomainRegistry.portfolioRepository.portfolio() {
            return result
        } else {
            return Portfolio(id: DomainRegistry.portfolioRepository.nextID())
        }
    }

    public func deployWallet(subscriber: EventSubscriber, onError: ((Swift.Error) -> Void)?) {
        if let errorHandler = onError {
            DomainRegistry.errorStream.removeHandler(subscriber)
            DomainRegistry.errorStream.addHandler(subscriber, errorHandler)
        }
        ApplicationServiceRegistry.eventRelay.unsubscribe(subscriber)
        [DeploymentStarted.self,
         WalletConfigured.self,
         DeploymentFunded.self,
         CreationStarted.self,
         WalletTransactionHashIsKnown.self,
         WalletCreated.self,
         WalletCreationFailed.self].forEach {
            ApplicationServiceRegistry.eventRelay.subscribe(subscriber, for: $0)
        }
        DomainRegistry.deploymentService.start()
    }

    public func walletState() -> WalletStateId? {
        guard let state = selectedWallet?.state else { return nil }
        if state is FinalizingDeploymentState && selectedWallet!.creationTransactionHash != nil {
            return .transactionHashIsKnown
        }
        return WalletStateId(state)
    }

    private func notifyBrowserExtension(message: String) throws {
        guard let recipient = ownerAddress(of: .browserExtension) else { return }
        let sender = ownerAddress(of: .thisDevice)!
        let signedAddress = ethereumService.sign(message: "GNO" + message, by: sender)!
        let request = SendNotificationRequest(message: message, to: recipient, from: signedAddress)
        try handleNotificationServiceError {
            try notificationService.send(notificationRequest: request)
        }
    }

    public func abortDeployment() {
        mutateSelectedWallet { $0.cancel() }
    }

    private func mutateSelectedWallet(_ closure: (Wallet) -> Void) {
        let wallet = selectedWallet!
        closure(wallet)
        DomainRegistry.walletRepository.save(wallet)
    }

    private var selectedWallet: Wallet? {
        return DomainRegistry.walletRepository.selectedWallet()
    }

    public func walletCreationURL() -> URL {
        return configuration.transactionURL(for: selectedWallet!.creationTransactionHash!)
    }

    // MARK: - Owners

    public func isOwnerExists(_ type: OwnerType) -> Bool {
        let role = OwnerRole(rawValue: type.rawValue)!
        guard let wallet = selectedWallet, wallet.owner(role: role) != nil else { return false }
        return true
    }

    public func addOwner(address: String, type: OwnerType) {
        let role = OwnerRole(rawValue: type.rawValue)!
        mutateSelectedWallet { wallet in
            wallet.addOwner(Wallet.createOwner(address: address, role: role))
        }
    }

    public func addBrowserExtensionOwner(address: String, browserExtensionCode rawCode: String) throws {
        let deviceOwnerAddress = ownerAddress(of: .thisDevice)!
        let signature = ethereumService.sign(message: "GNO" + address, by: deviceOwnerAddress)!
        guard let code = browserExtensionCode(from: rawCode) else {
            throw WalletApplicationServiceError.validationFailed
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
            throw WalletApplicationServiceError.validationFailed
        } catch let JSONHTTPClient.Error.networkRequestFailed(request, response, data) {
            logNetworkError(request, response, data)
            if let data = data, let dataStr = String(data: data, encoding: .utf8),
                dataStr.range(of: "Exceeded expiration date") != nil {
                throw WalletApplicationServiceError.exceededExpirationDate
            } else if let response = response as? HTTPURLResponse {
                throw (400..<500).contains(response.statusCode) ?
                    WalletApplicationServiceError.clientError : WalletApplicationServiceError.serverError
            } else {
                throw WalletApplicationServiceError.networkError
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

    private func logNetworkError(_ request: URLRequest, _ response: URLResponse?, _ data: Data?) {
        #if DEBUG
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
        #endif
    }

    private func error(from response: URLResponse?) -> WalletApplicationServiceError {
        if let response = response as? HTTPURLResponse {
            if (400..<500).contains(response.statusCode) {
                return .clientError
            } else {
                return .serverError
            }
        }
        return .networkError
    }

    private func error(from other: NetworkServiceError) -> WalletApplicationServiceError {
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
        let role = OwnerRole(rawValue: type.rawValue)!
        guard let wallet = selectedWallet, let owner = wallet.owner(role: role) else { return nil }
        return owner.address
    }

    // MARK: - Tokens

    /// Subscribe on updates about token balances changes and other changes influencing tokens list presentation.
    ///
    /// - Parameter subscriber: subscriber.
    public func subscribeOnTokensUpdates(subscriber: EventSubscriber) {
        DomainRegistry.errorStream.removeHandler(subscriber)
        DomainRegistry.errorStream.addHandler(subscriber, tokensListUpdatesErrorHandler)
        ApplicationServiceRegistry.eventRelay.unsubscribe(subscriber)
        ApplicationServiceRegistry.eventRelay.subscribe(subscriber, for: AccountsBalancesUpdated.self)
        ApplicationServiceRegistry.eventRelay.subscribe(subscriber, for: TokensDisplayListChanged.self)
    }

    private func tokensListUpdatesErrorHandler(error: Error) {
        if let err = error as? TokensListError {
            switch err {
            case .inconsistentData_notAmongWhitelistedToken:
                ApplicationServiceRegistry.logger.error(
                    "Trying to rearrange not equal to whitelisted amount tokens",
                    error: err)
            case .inconsistentData_notEqualToWhitelistedAmount:
                ApplicationServiceRegistry.logger.error(
                    "Trying to rearrange token that is not among whitelisted",
                    error: err)
            }
        }
    }

    public func syncBalances() {
        precondition(!Thread.isMainThread)
        DomainRegistry.syncService.sync()
    }

    public func tokenData(id: String) -> TokenData? {
        guard let token = self.token(id: id) else { return nil }
        let balance = accountBalance(tokenID: token.id)
        return TokenData(token: token, balance: balance)
    }

    private func token(id: String) -> Token? {
        if id == Token.Ether.id.id {
            return Token.Ether
        } else {
            return DomainRegistry.tokenListItemRepository.find(id: TokenID(id))?.token
        }
    }

    /// Returns selected account Eth Data together with whitelisted tokens data.
    ///
    /// - Parameter withEth: should the Eth be amoung Token Data returned or not.
    /// - Returns: token data array.
    public func visibleTokens(withEth: Bool) -> [TokenData] {
        guard let wallet = selectedWallet else { return [] }
        let tokens: [TokenData] = DomainRegistry.tokenListItemRepository.whitelisted().compactMap {
            guard let account = DomainRegistry.accountRepository.find(
                id: AccountID(tokenID: $0.id, walletID: wallet.id)) else { return nil }
            return TokenData(token: $0.token, balance: account.balance)
        }
        guard withEth else { return tokens }
        let ethAccount = DomainRegistry.accountRepository.find(
            id: AccountID(tokenID: Token.Ether.id, walletID: wallet.id))!
        let ethData = TokenData(token: Token.Ether, balance: ethAccount.balance)
        return [ethData] + tokens
    }

    /// Returns all tokens that are not whitelisted.
    ///
    /// - Returns: token data array.
    public func hiddenTokens() -> [TokenData] {
        return DomainRegistry.tokenListItemRepository.all()
            .filter { $0.status != .whitelisted }
            .compactMap { TokenData(token: $0.token, balance: nil) }
    }

    /// Whitelist a token.
    ///
    /// - Parameter tokenData: necessary token data
    public func whitelist(token tokenData: TokenData) {
        DomainRegistry.tokenListItemRepository.whitelist(tokenData.token())
    }

    /// Blacklist a token.
    ///
    /// - Parameter tokenData: necessary token data
    public func blacklist(token tokenData: TokenData) {
        DomainRegistry.tokenListItemRepository.blacklist(tokenData.token())
    }

    /// Rearrange whitelisted tokens with new sorting ids.
    ///
    /// - Parameter tokens: new sorting order of tokens.
    public func rearrange(tokens: [TokenData]) {
        DomainRegistry.tokenListItemRepository.rearrange(tokens: tokens.map { $0.token() })
    }

    // MARK: - Accounts

    public func accountBalance(tokenID: BaseID) -> BigInt? {
        let account = findAccount(TokenID(tokenID.id))
        return account?.balance
    }

    private func assertCanChangeAccount() {
        try! assertTrue(canChangeAccount, WalletApplicationServiceError.invalidWalletState)
    }

    public func update(account tokenID: TokenID, newBalance: BigInt) {
        assertCanChangeAccount()
        mutateAccount(tokenID: tokenID) { account in
            account.update(newAmount: newBalance)
        }
    }

    private func mutateAccount(tokenID: TokenID, closure: (Account) -> Void) {
        let account = findAccount(tokenID)!
        closure(account)
        DomainRegistry.accountRepository.save(account)
    }

    // MARK: - Transactions

    public func subscribeForTransactionUpdates(subscriber: EventSubscriber) {
        ApplicationServiceRegistry.eventRelay.unsubscribe(subscriber)
        ApplicationServiceRegistry.eventRelay.subscribe(subscriber, for: TransactionStatusUpdated.self)
    }

    public func transactionURL(_ id: String) -> URL {
        let tx = DomainRegistry.transactionRepository.findByID(TransactionID(id))!
        return configuration.transactionURL(for: tx.transactionHash!.value)
    }

    public func grouppedTransactions() -> [TransactionGroupData] {
        return DomainRegistry.transactionService.grouppedTransactions().map { group in
            TransactionGroupData(type: .init(group.type),
                                 date: group.date,
                                 transactions: group.transactions.map { transactionData($0) })
        }
    }

    public func updateTransaction(_ id: String, amount: BigInt, token: String, recipient: String) {
        let transaction = DomainRegistry.transactionRepository.findByID(TransactionID(id))!
        let tokenItem = DomainRegistry.tokenListItemRepository.find(id: TokenID(token))!
        transaction
            .change(amount: TokenAmount(amount: amount, token: tokenItem.token))
            .change(recipient: Address(recipient))
        if tokenItem.token != .Ether {
            let proxy = ERC20TokenContractProxy(tokenItem.token.address)
            let data = proxy.transfer(to: Address(recipient), amount: amount)
            transaction.change(data: data)
        }
        DomainRegistry.transactionRepository.save(transaction)
    }

    public func removeDraftTransaction(_ id: String) {
        DomainRegistry.transactionService.removeDraftTransaction(TransactionID(id))
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
        return (BigInt(response.dataGas) + BigInt(response.safeTxGas) + BigInt(response.operationalGas))
            * BigInt(response.gasPrice)
    }

    public func estimateTransferFee(amount: BigInt, token: String, recipient: String?) -> BigInt? {
        let fallbackAddress = Address(ownerAddress(of: .thisDevice)!)
        var address = recipient == nil || recipient!.isEmpty ? fallbackAddress.value : recipient!
        var data: String?
        var value: BigInt = amount
        if token != Token.Ether.id.id {
            data = "0x" + ERC20TokenContractProxy(Address(address))
                .transfer(to: Address(address), amount: amount).toHexString()
            address = token
            value = 0
        }
        guard let to = DomainRegistry.encryptionService.address(from: address),
            let safe = DomainRegistry.encryptionService.address(from: selectedWalletAddress!) else {
                return nil
        }
        let request = EstimateTransactionRequest(safe: safe,
                                                 to: to,
                                                 value: String(value),
                                                 data: data,
                                                 operation: .call)
        guard let response = try? DomainRegistry.transactionRelayService.estimateTransaction(request: request) else {
            return nil
        }
        return (BigInt(response.dataGas) + BigInt(response.safeTxGas) + BigInt(response.operationalGas))
            * BigInt(response.gasPrice)
    }

    public func transactionData(_ id: String) -> TransactionData? {
        guard let tx = DomainRegistry.transactionRepository.findByID(TransactionID(id)) else { return nil }
        return transactionData(tx)
    }

    private func transactionData(_ tx: Transaction) -> TransactionData {
        let type = TransactionData.TransactionType.outgoing
        let amountTokenData = tx.amount != nil ?
            TokenData(token: tx.amount!.token,
                      balance: (type == .outgoing ? -1 : 1) * (tx.amount?.amount ?? 0)) :
            TokenData.empty()
        let feeTokenData = tx.fee != nil ?
            TokenData(token: tx.fee!.token, balance: tx.fee!.amount) :
            TokenData(token: Token.Ether, balance: nil)
        return TransactionData(id: tx.id.id,
                               sender: tx.sender?.value ?? "",
                               recipient: tx.recipient?.value ?? "",
                               amountTokenData: amountTokenData,
                               feeTokenData: feeTokenData,
                               status: status(of: tx),
                               type: .outgoing,
                               created: tx.createdDate,
                               updated: tx.updatedDate,
                               submitted: tx.submittedDate,
                               rejected: tx.rejectedDate,
                               processed: tx.processedDate)
    }

    private func status(of tx: Transaction) -> TransactionData.Status {
        // TODO: refactor to have similar statuses of transaction in domain model and app
        let hasBrowserExtension = address(of: .browserExtension) != nil
        let defaultStatus = hasBrowserExtension ? TransactionData.Status.waitingForConfirmation : .readyToSubmit
        switch tx.status {
        case .signing:
            let isSignedByExtension = hasBrowserExtension &&
                tx.signatures.count == 1
                && tx.isSignedBy(address(of: .browserExtension)!)
            return isSignedByExtension ? .readyToSubmit : defaultStatus
        case .rejected: return .rejected
        case .pending: return .pending
        case .failed: return .failed
        case .success: return .success
        case .discarded: return .discarded
        case .draft: return defaultStatus
        }
    }

    public func createNewDraftTransaction() -> String {
        let newTransactionID = DomainRegistry.transactionService.newDraftTransaction()
        return newTransactionID.id
    }

    public func requestTransactionConfirmation(_ id: String) throws -> TransactionData {
        let tx = DomainRegistry.transactionRepository.findByID(TransactionID(id))!
        if tx.status == .draft {
            let (estimation, nonce) = try estimateTransaction(tx)
            let fee = TokenInt(estimation.gas + estimation.dataGas) * estimation.gasPrice.amount
            tx.change(feeEstimate: estimation)
                .change(fee: TokenAmount(amount: fee, token: estimation.gasPrice.token))
            tx.change(nonce: String(nonce))
                .change(operation: .call)
                .change(hash: ethereumService.hash(of: tx))
                .proceed()
            DomainRegistry.transactionRepository.save(tx)
        }
        if let extensionAddress = address(of: .browserExtension), !tx.isSignedBy(extensionAddress) {
            try notifyBrowserExtension(message: notificationService.requestConfirmationMessage(for: tx, hash: tx.hash!))
        }
        return transactionData(id)!
    }

    private func estimateTransaction(_ tx: Transaction) throws -> (TransactionFeeEstimate, Int) {
        let recipient = DomainRegistry.encryptionService.address(from: tx.ethTo.value)!
        let request = EstimateTransactionRequest(safe: tx.sender!,
                                                 to: recipient,
                                                 value: String(tx.ethValue),
                                                 data: tx.ethData,
                                                 operation: .call)

        let estimationResponse = try handleRelayServiceErrors {
            try DomainRegistry.transactionRelayService.estimateTransaction(request: request)
        }
        // TODO: get token from Tokens List by estimationResponse.gasToken address and use Ether as fallback
        let token = Token.Ether
        let feeEstimate = TransactionFeeEstimate(gas: estimationResponse.safeTxGas,
                                                 dataGas: estimationResponse.dataGas,
                                                 operationalGas: estimationResponse.operationalGas,
                                                 gasPrice: TokenAmount(amount: TokenInt(estimationResponse.gasPrice),
                                                                       token: token))
        return (feeEstimate, estimationResponse.nextNonce)
    }

    public enum TransactionError: Swift.Error {
        case unsignedTransaction
    }

    public func submitTransaction(_ id: String) throws -> TransactionData {
        let tx = DomainRegistry.transactionRepository.findByID(TransactionID(id))!
        signTransaction(tx)
        let hash = try submitTransaction(tx)
        tx.set(hash: hash).proceed()
        DomainRegistry.transactionRepository.save(tx)
        try? notifyBrowserExtension(message: notificationService.transactionSentMessage(for: tx))
        return transactionData(id)!
    }

    private func signTransaction(_ tx: Transaction) {
        if let extensionAddress = address(of: .browserExtension) {
            try! assertTrue(tx.isSignedBy(extensionAddress), TransactionError.unsignedTransaction)
        }
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

    private func findAccount(_ tokenID: TokenID) -> Account? {
        guard let wallet = selectedWallet,
            let account = DomainRegistry.accountRepository.find(
                id: AccountID(tokenID: tokenID, walletID: wallet.id)) else {
            return nil
        }
        return account
    }

    // MARK: - Notifications

    public func auth() throws {
        precondition(!Thread.isMainThread)
        guard let pushToken = pushTokensService.pushToken() else { return }
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
        } else if let sending = message as? SendTransactionMessage {
            return handle(message: sending)
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
        guard let transaction = DomainRegistry.transactionRepository.findBy(hash: message.hash, status: .signing),
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
        transaction.reject()
        DomainRegistry.transactionRepository.save(transaction)
        return transaction.id.id
    }

    func handle(message: SendTransactionMessage) -> String? {
        if let transaction = DomainRegistry.transactionRepository.findBy(hash: message.hash) {
            return transaction.status == .signing ? transaction.id.id : nil
        }
        guard let wallet = DomainRegistry.walletRepository.findByAddress(message.safe) else { return nil }
        let transactionID = DomainRegistry.transactionService.newDraftTransaction(in: wallet)
        let transaction = DomainRegistry.transactionRepository.findByID(transactionID)!
        update(transaction: transaction, with: message)
        let hash = DomainRegistry.encryptionService.hash(of: transaction)
        guard hash == message.hash else {
            DomainRegistry.transactionRepository.remove(transaction)
            return nil
        }
        transaction.change(hash: hash)
        guard let sender = ethereumService.address(hash: message.hash, signature: message.signature),
            let extensionAddress = ownerAddress(of: .browserExtension),
            sender.value.lowercased() == extensionAddress.lowercased() else {
                DomainRegistry.transactionRepository.remove(transaction)
                return nil
        }
        transaction.proceed()
        let signature = Signature(data: DomainRegistry.encryptionService.data(from: message.signature),
                                  address: Address(extensionAddress))
        transaction.add(signature: signature)
        DomainRegistry.transactionRepository.save(transaction)
        return transactionID.id
    }

    private func update(transaction: Transaction, with message: SendTransactionMessage) {
        transaction
            .change(recipient: message.to)
            .change(data: message.data)
            .change(amount: TokenAmount.ether(message.value))
            .change(operation: message.operation)
            .change(feeEstimate: self.estimation(message))
            .change(fee: self.fee(message))
            .change(nonce: String(message.nonce))

        if let erc20Transfer = ERC20TokenContractProxy(message.to).decodedTransfer(from: message.data) {
            transaction
                .change(recipient: erc20Transfer.recipient)
                .change(amount: TokenAmount(amount: erc20Transfer.amount,
                                            token: Token.init(code: "",
                                                              name: "",
                                                              decimals: 18,
                                                              address: message.to,
                                                              logoUrl: "")))
        }
    }

    private func estimation(_ message: SendTransactionMessage) -> TransactionFeeEstimate {
        return TransactionFeeEstimate(gas: message.txGas,
                                      dataGas: message.dataGas,
                                      operationalGas: message.operationalGas,
                                      gasPrice: TokenAmount(amount: message.gasPrice,
                                                            token: Token(code: "",
                                                                         name: "",
                                                                         decimals: 18,
                                                                         address: message.gasToken,
                                                                         logoUrl: "")))

    }

    private func fee(_ message: SendTransactionMessage) -> TokenAmount {
        let estimation = self.estimation(message)
        let fee = TokenInt(estimation.gas + estimation.dataGas) * estimation.gasPrice.amount
        return TokenAmount(amount: fee, token: estimation.gasPrice.token)
    }

}

extension TransactionGroupData.GroupType {

    init(_ type: TransactionGroup.GroupType) {
        switch type {
        case .pending: self = .pending
        case .processed: self = .processed
        }
    }
}
