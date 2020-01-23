//
//  Copyright © 2020 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import Common
import CryptoSwift

// API defined in a model protocol

// transaction service will load and return incoming transactions and outgoing transactions for a safe

public class HTTPGnosisTransactionService: SafeTransactionDomainService {

    private let httpClient: JSONHTTPClient

    public init(url: URL) {
        httpClient = JSONHTTPClient(url: url)
        // 2020-01-22T13:11:59.838510Z
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        // 2020-01-22T13:11:48Z
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        httpClient.jsonDecoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
            let c = try decoder.singleValueContainer()
            let str = try c.decode(String.self)
            if let date = formatter1.date(from: str) {
                return date
            } else if let date = formatter2.date(from: str) {
                return date
            } else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath,
                                                                        debugDescription: "Date! \(str)"))
            }
        })

    }

    public func transactions(safe: Address) -> [Transaction] {
        var result = [Transaction]()
        do {
            let responseTransactions = try httpClient.execute(request: GetSafeTransactionsRequest(safe: safe.value))
            print(responseTransactions)
            result += responseTransactions.results.map { $0.transaction(in: safe) }
        } catch {
            print("Error: \(error)")
        }
        do {
            let responseIncoming = try httpClient.execute(request: GetIncomingSafeTransactionsRequest(safe: safe.value))
            result += responseIncoming.results.map { $0.transaction(in: safe) }
        } catch {
            print("Error: \(error)")
        }
        return result
    }

    public func safes(by owner: Address) throws -> [String] {
        let response = try httpClient.execute(request: GetSafesByOwnerRequest(owner: owner.value))
        return response.safes
    }

}

struct GetSafesByOwnerRequest: Encodable, JSONRequest {

    let owner: String

    var httpMethod: String { return "GET" }
    var urlPath: String { return "/api/v1/owners/\(owner)/" }

    typealias ResponseType = Response

    struct Response: Decodable {
        let safes: [String]
    }

}

struct SafeTransactionServiceResponse<T>: Decodable where T: Decodable {
    // number of results
    var count: Int
    // next page url
    var next: String?
    // previous page url
    var previous: String?
    // resulting objects
    var results: [T]
}

struct GetIncomingSafeTransactionsRequest: Encodable, JSONRequest {

    typealias ResponseType = SafeTransactionServiceResponse<IncomingTransaction>

    var httpMethod: String { "GET" }
    var urlPath: String { "/api/v1/safes/\(safe)/incoming-transactions/" }
    var query: String? { return "limit=5000" }

    var safe: String

    struct IncomingTransaction: Decodable {

        var executionDate: Date

        var blockNumber: Int

        var transactionHash: EthData

        var to: EthAddress

        var value: EthInt

        var tokenAddress: EthAddress?

        var from: EthAddress
    }
}

extension GetIncomingSafeTransactionsRequest.IncomingTransaction {

    func transaction(in safe: Address) -> Transaction {
        let txID = DomainRegistry.transactionRepository.nextID()
        let walletID = DomainRegistry.walletRepository.find(address: safe)?.id ?? DomainRegistry.walletRepository.nextID()
        let tokenID = TokenID(tokenAddress?.address.value ?? Token.Ether.id.id)
        let token = DomainRegistry.transactionService.token(for: Address(tokenID.id))
        let tx = Transaction(
            id: txID,
            type: .transfer,
            accountID: AccountID(
                tokenID: tokenID,
                walletID: walletID)
            )
            .change(sender: from.address)
            .change(recipient: to.address)
            .change(amount: TokenAmount(amount: value.value, token: token))
            .change(fee: TokenAmount(amount: 0, token: .Ether))
            .change(feeEstimate: TransactionFeeEstimate(gas: 0, dataGas: 0, operationalGas: 0, gasPrice: TokenAmount(amount: 0, token: .Ether)))
            .set(hash: TransactionHash(transactionHash.hexString))
            .timestampCreated(at: executionDate)
            .timestampUpdated(at: executionDate)
            .timestampSubmitted(at: executionDate)
            .timestampProcessed(at: executionDate)
            .change(status: .success)
        return tx
    }

}


struct GetSafeTransactionsRequest: Encodable, JSONRequest {

    typealias ResponseType = SafeTransactionServiceResponse<MultisigTransaction>

    var httpMethod: String { "GET" }
    var urlPath: String { "/api/v1/safes/\(safe)/transactions/" }
    var query: String? { return "limit=5000" }

    var safe: String


    struct MultisigTransaction: Decodable {

        // address
        var safe: EthAddress

        // address
        var to: EthAddress?

        // big-integer in base10
        var value: EthInt

        // hex bytes string
        var data: EthData?

        // 0, 1
        var operation: Int

        // address, can also be zero address for eth
        var gasToken: EthAddress?

        var safeTxGas: Int

        var baseGas: Int

        // big-int base10
        var gasPrice: EthInt

        // address, 0x0 address possible
        var refundReceiver: EthAddress?

        var nonce: Int

        // 32-byte hex
        var safeTxHash: EthData

        var blockNumber: Int?

        // 32-byte hex;
        var transactionHash: EthData?

        // date (2019-12-17T12:04:46.611279Z) - created at
        var submissionDate: Date

        var isExecuted: Bool

        var isSuccessful: Bool?

        // date - processed at
        var executionDate: Date?

        // address
        var executor: EthAddress?

        var gasUsed: Int?

        var confirmations: [Confirmation]?

        var signatures: EthData?

        struct Confirmation: Decodable {

            // address
            var owner: EthAddress

            // date
            var submissionDate: Date

            // nullable
            var transactionHash: EthData?

            // CONFIRMATION or EXECUTION
            var confirmationType: String

            // 32-byte hex
            var signature: EthData
        }
    }

}

extension GetSafeTransactionsRequest.MultisigTransaction {

    func transaction(in safe: Address) -> Transaction {
        let txID = DomainRegistry.transactionRepository.nextID()
        let walletID = DomainRegistry.walletRepository.find(address: safe)?.id ?? DomainRegistry.walletRepository.nextID()

        let tokenID: TokenID

        if let contract = to, let data = data,
            ERC20TokenContractProxy(contract.address).decodedTransfer(from: data.data) != nil {
            tokenID = TokenID(contract.address.value)
        } else {
            tokenID = Token.Ether.id
        }

        let gasTokenAddress = (self.gasToken ?? EthAddress.zero).address
        let gasToken = DomainRegistry.transactionService.token(for: gasTokenAddress)

        let feeEstimate = TransactionFeeEstimate(gas: TokenInt(safeTxGas),
                                                 dataGas: TokenInt(baseGas),
                                                 operationalGas: 0,
                                                 gasPrice: TokenAmount(amount: gasPrice.value, token: gasToken))

        let amountToken = DomainRegistry.transactionService.token(for: Address(tokenID.id))

        let tx = Transaction(
            id: txID,
            type: .transfer,
            accountID: AccountID(
                tokenID: tokenID,
                walletID: walletID)
            )
            .change(sender: self.safe.address)
            .change(recipient: to?.address ?? Token.Ether.address)
            .change(amount: TokenAmount(amount: value.value, token: amountToken))
            .change(data: data?.data)
            .change(operation: WalletOperation(rawValue: operation) ?? .call)
            .change(fee: feeEstimate.totalSubmittedToBlockchain)
            .change(feeEstimate: feeEstimate)
            .change(nonce: String(nonce))
            .change(hash: safeTxHash.data)

        if let hash = transactionHash {
            tx.set(hash: TransactionHash(hash.hexString))
        }

        tx.timestampCreated(at: submissionDate)
            .timestampUpdated(at: submissionDate)
            .timestampSubmitted(at: submissionDate)

        if isExecuted && isSuccessful == true {
            tx.change(status: .success)
        } else if isExecuted && (isSuccessful == false || isSuccessful == nil) {
            tx.change(status: .failed)
        } else if !isExecuted && transactionHash == nil {
            tx.change(status: .signing)
        } else if !isExecuted && transactionHash != nil {
            tx.change(status: .pending)
        }

        if let date = executionDate {
            tx.timestampProcessed(at: date)
        }

        if let confirmations = confirmations {
            for confirmation in confirmations {
                tx.add(signature: confirmation.modelSignature)
            }
        }

        if let to = to, let data = data {
            DomainRegistry.transactionService.enhanceWithERC20Data(transaction: tx, to: to.address, data: data.data)
        }

        return tx
    }

}

extension GetSafeTransactionsRequest.MultisigTransaction.Confirmation {

    var modelSignature: Signature {
        Signature(data: signature.data, address: owner.address)
    }

}


/*
This is a paged data source.

 "/safes/{address}/transactions/": {
 "get": {
     "operationId": "safes_transactions_list",
     "description": "Returns the history of a multisig tx (safe)",
     "parameters": [
         {
             "name": "executed",
             "in": "query",
             "description": "",
             "required": false,
             "type": "string"
         },
         {
             "name": "nonce__lt",
             "in": "query",
             "description": "",
             "required": false,
             "type": "number"
         },
         {
             "name": "nonce__gt",
             "in": "query",
             "description": "",
             "required": false,
             "type": "number"
         },
         {
             "name": "nonce",
             "in": "query",
             "description": "",
             "required": false,
             "type": "number"
         },
         {
             "name": "safe_tx_hash",
             "in": "query",
             "description": "",
             "required": false,
             "type": "string"
         },
         {
             "name": "value__lt",
             "in": "query",
             "description": "",
             "required": false,
             "type": "number"
         },
         {
             "name": "value__gt",
             "in": "query",
             "description": "",
             "required": false,
             "type": "number"
         },
         {
             "name": "value",
             "in": "query",
             "description": "",
             "required": false,
             "type": "number"
         },
         {
             "name": "execution_date__gte",
             "in": "query",
             "description": "",
             "required": false,
             "type": "string"
         },
         {
             "name": "execution_date__lte",
             "in": "query",
             "description": "",
             "required": false,
             "type": "string"
         },
         {
             "name": "submission_date__gte",
             "in": "query",
             "description": "",
             "required": false,
             "type": "string"
         },
         {
             "name": "submission_date__lte",
             "in": "query",
             "description": "",
             "required": false,
             "type": "string"
         },
         {
             "name": "transaction_hash",
             "in": "query",
             "description": "",
             "required": false,
             "type": "string"
         },
         {
             "name": "limit",
             "in": "query",
             "description": "Number of results to return per page.",
             "required": false,
             "type": "integer"
         },
         {
             "name": "offset",
             "in": "query",
             "description": "The initial index from which to return the results.",
             "required": false,
             "type": "integer"
         }
     ],
     "responses": {
         "200": {
             "description": "",
             "schema": {
                 "required": [
                     "count",
                     "results"
                 ],
                 "type": "object",
                 "properties": {
                     "count": {
                         "type": "integer"
                     },
                     "next": {
                         "type": "string",
                         "format": "uri",
                         "x-nullable": true
                     },
                     "previous": {
                         "type": "string",
                         "format": "uri",
                         "x-nullable": true
                     },
                     "results": {
                         "type": "array",
                         "items": {
                             "$ref": "#/definitions/SafeMultisigTransactionResponse"
                         }
                     }
                 }
             }
         },
         "400": {
             "description": "Invalid data"
         },
         "404": {
             "description": "Not found"
         },
         "422": {
             "description": "Invalid ethereum address"
         }
     },
     "tags": [
         "safes"
     ]
 },

 "SafeMultisigTransactionResponse": {
     "required": [
         "safe",
         "value",
         "operation",
         "safeTxGas",
         "baseGas",
         "gasPrice",
         "nonce",
         "safeTxHash",
         "transactionHash",
         "submissionDate",
         "isExecuted",
         "executionDate",
         "signatures"
     ],
     "type": "object",
     "properties": {
         "safe": {                          // sender
             "title": "Safe",
             "type": "string"
         },
         "to": {                            // recipient
             "title": "To",
             "type": "string",
             "x-nullable": true
         },
         "value": {                       // eth amount
             "title": "Value",
             "type": "string",
             "minLength": 1
         },
         "data": {                          // data
             "title": "Data",
             "type": "string",
             "x-nullable": true
         },
         "operation": {                    // operation
             "title": "Operation",
             "type": "integer",
             "minimum": 0
         },
         "gasToken": {                     // feeEstimate.gasPrice.token
             "title": "Gas token",
             "type": "string",
             "x-nullable": true
         },
         "safeTxGas": {                     // feeEstimate.gas
             "title": "Safe tx gas",
             "type": "integer",
             "minimum": 0
         },
         "baseGas": {                      // feeEstimate.baseGas
             "title": "Base gas",
             "type": "integer",
             "minimum": 0
         },
         "gasPrice": {                      // feeEstimate.gasPrice.amount
             "title": "Gas price",
             "type": "string",
             "minLength": 1
         },
         "refundReceiver": {                //  this is used for the transaction hash. Needs to be added. By default is 'false'
             "title": "Refund receiver",    // but when it is present - is it address of the receiver?
             "type": "string",
             "x-nullable": true
         },
         "nonce": {                         // nonce
             "title": "Nonce",
             "type": "integer",
             "minimum": 0
         },
         "safeTxHash": {                    //  hash
             "title": "Safe tx hash",
             "type": "string"
         },
         "blockNumber": {                  // No such field yet.
             "title": "Block number",
             "type": "integer",
             "readOnly": true
         },
         "transactionHash": {               // transactionHash
             "title": "Transaction hash",
             "type": "string"
         },
         "submissionDate": {                // submittedDate -- is it submission to blockchain?
             "title": "Submission date",
             "type": "string",
             "format": "date-time"
         },
         "isExecuted": {                    // !isExecuted && not submitted (no date) --> status = .signing
             "title": "Is executed",        // isExecuted && isSuccessful --> status = .success
             "type": "boolean"              // isExecuted && !isSuccessful --> status = .failed
         },                                 // !isExecuted && submitted  --> status = .pending
         "isSuccessful": {
             "title": "Is successful",
             "type": "boolean",
             "readOnly": true
         },
         "executionDate": {                 // processedDate
             "title": "Execution date",
             "type": "string",
             "format": "date-time"
         },
         "executor": {                      // No such field yet. address of the executor?
             "title": "Executor",
             "type": "string",
             "readOnly": true
         },
         "gasUsed": {                       // No such field yet. actual gas, not estimated?
             "title": "Gas used",
             "type": "string",
             "readOnly": true
         },
         "confirmations": {                // signatures.
             "title": "Confirmations",
             "type": "string",
             "readOnly": true
         },

 "confirmations": [
   {
     "owner": "0xb899bE62dB3C948225Bc0f059EF683E27C01cc95", // signature.address
     "submissionDate": "2019-12-17T11:59:29.405298Z",       // signing date
     "transactionHash": null,
     "confirmationType": "CONFIRMATION",
     "signature":                                           // signature.data "0x36bb6122804c4f7f17907b08381832d9ef6a23513d201d7219e36f7b3e102f546514303e61b3b0ce4173dd9fe56a31a65d1a520820d53e12bb793a5a1e92d6c11b"
   },

         "signatures": {
             "title": "Signatures",         // No such field yet. Encoded signatures byte string. signatures.
             "type": "string"
         }
     }
 },
 */
