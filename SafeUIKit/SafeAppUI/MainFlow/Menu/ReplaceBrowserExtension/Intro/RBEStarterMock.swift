//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
@testable import SafeAppUI
import XCTest
import MultisigWalletApplication

class RBEStarterMock: RBEStarter {

    func create() -> RBETransactionID {
        let actualCall: CreateCall
        if let expected: CreateCall = nextCall() {
            actualCall = CreateCall(returns: expected.returns)
        } else {
            actualCall = CreateCall(returns: "<unexpected>")
        }
        actualCalls.append(actualCall)
        return actualCall.returns
    }

    func recreateTransactionIfPaymentMethodChanged(transaction: RBETransactionID) -> RBETransactionID {
        let actualCall: RecreateCall
        if let expected: RecreateCall = nextCall() {
            actualCall = RecreateCall(returns: expected.returns)
        } else {
            actualCall = RecreateCall(returns: "<unexpected>")
        }
        actualCalls.append(actualCall)
        return actualCall.returns
    }

    func estimate(transaction: RBETransactionID) -> RBEEstimationResult {
        let actualCall: EstimateCall
        if let expected: EstimateCall = nextCall() {
            actualCall = EstimateCall(transaction: transaction, returns: expected.returns)
        } else {
            actualCall = EstimateCall(transaction: transaction, returns: RBEEstimationResult.zero)
        }
        actualCalls.append(actualCall)
        return actualCall.returns
    }

    func start(transaction: RBETransactionID) throws {
        let actualCall: StartCall
        if let expected: StartCall = nextCall() {
            actualCall = StartCall(transaction: transaction, throwing: expected.throwing)
        } else {
            actualCall = StartCall(transaction: transaction, throwing: nil)
        }
        actualCalls.append(actualCall)
        if let error = actualCall.throwing {
            throw error
        }
    }

    var callIndex = 0

    func nextCall<T>() -> T? where T: Call {
        guard callIndex < expectedCalls.count, let result = expectedCalls[callIndex] as? T else { return nil }
        callIndex += 1
        return result
    }


    class Call: Equatable, CustomStringConvertible {

        var methodSignature: String { preconditionFailure() }

        static func == (lhs: RBEStarterMock.Call, rhs: RBEStarterMock.Call) -> Bool {
            return lhs.equals(rhs)
        }

        func equals(_ rhs: RBEStarterMock.Call) -> Bool {
            return methodSignature == rhs.methodSignature
        }

        var description: String {
            return methodSignature
        }

    }


    class CreateCall: Call {

        override var methodSignature: String { return "create()" }
        var returns: RBETransactionID

        init(returns: RBETransactionID) {
            self.returns = returns
        }

        override var description: String {
            return "\(methodSignature) -> \(returns.debugDescription)"
        }

        override func equals(_ rhs: RBEStarterMock.Call) -> Bool {
            return super.equals(rhs) && rhs is CreateCall && returns == (rhs as! CreateCall).returns
        }

    }

    class RecreateCall: CreateCall {

        override var methodSignature: String { return "recreateTransactionIfPaymentMethodChanged(transaction:)" }

        override func equals(_ rhs: RBEStarterMock.Call) -> Bool {
            return super.equals(rhs) && rhs is RecreateCall && returns == (rhs as! RecreateCall).returns
        }

    }

    class EstimateCall: Call {

        override var methodSignature: String { return "estimate(transaction:)" }

        var transaction: RBETransactionID
        var returns: RBEEstimationResult

        init(transaction: RBETransactionID, returns: RBEEstimationResult) {
            self.transaction = transaction
            self.returns = returns
        }

        override func equals(_ rhs: RBEStarterMock.Call) -> Bool {
            guard super.equals(rhs), let rhs = rhs as? EstimateCall else { return false }
            return transaction == rhs.transaction && returns == rhs.returns
        }

        override var description: String {
            return "estimate(transaction: \(transaction.debugDescription)) -> \(returns.debugDescription)"
        }

    }

    class StartCall: Call {

        override var methodSignature: String { return "start(transaction:)" }

        var transaction: RBETransactionID
        var throwing: Error?

        init(transaction: RBETransactionID, throwing: Error?) {
            self.transaction = transaction
            self.throwing = throwing
        }

        override func equals(_ rhs: RBEStarterMock.Call) -> Bool {
            guard super.equals(rhs), let rhs = rhs as? StartCall else { return false }
            return transaction == rhs.transaction && String(describing: throwing) == String(describing: rhs.throwing)
        }

        override var description: String {
            return "start(transaction: \(transaction.debugDescription)) throws \(String(describing: throwing))"
        }

    }

    func expect_create(returns: RBETransactionID) {
        expect(CreateCall(returns: returns))
    }

    func expect_recreate(returns: RBETransactionID) {
        expect(RecreateCall(returns: returns))
    }

    func expect_estimate(transaction: RBETransactionID, returns: RBEEstimationResult) {
        expect(EstimateCall(transaction: transaction, returns: returns))
    }

    func expect_start(transaction: RBETransactionID, throwing: Error?) {
        expect(StartCall(transaction: transaction, throwing: throwing))
    }

    var expectedCalls = [Call]()
    var actualCalls = [Call]()

    func expect<T>(_ call: T) where T: Call {
        expectedCalls.append(call)
    }

    func verify(file: StaticString = #file, line: UInt = #line) {
        var (expectedIndex, actualIndex) = (0, 0)
        while expectedIndex < expectedCalls.count && actualIndex < actualCalls.count {
            let expectedCall = expectedCalls[expectedIndex]
            let actualCall = actualCalls[actualIndex]
            if expectedCall != actualCall {
                XCTFail("Expected call to \(expectedCall) but got \(actualCall)", file: file, line: line)
            }
            expectedIndex += 1
            actualIndex += 1
        }
        if expectedCalls.count > actualCalls.count {
            let calls = expectedCalls[actualCalls.count..<expectedCalls.count]
                .map { String(describing: $0) }.joined(separator: "\n")
            XCTFail("Expected calls \(calls) but they were not called", file: file, line: line)
        } else if expectedCalls.count < actualCalls.count {
            let calls = actualCalls[expectedCalls.count..<actualCalls.count]
                .map { String(describing: $0) }.joined(separator: "\n")
            XCTFail("Unexpected calls \(calls)", file: file, line: line)
        }
    }

}
