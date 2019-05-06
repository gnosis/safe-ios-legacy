//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
@testable import MultisigWalletImplementations

class TokenListMergerTests: XCTestCase {

    let tokenListService = MockTokenListService()
    let tokenListItemRepository = InMemoryTokenListItemRepository()
    let publisher = MockEventPublisher()
    var merger: TokenListMerger!

    var itemA: TokenListItem {
        return tokenListItemRepository.find(id: TokenID(TokenListStub.A_Address))!
    }
    var itemB: TokenListItem {
        return tokenListItemRepository.find(id: TokenID(TokenListStub.B_Address))!
    }
    var itemC: TokenListItem {
        return tokenListItemRepository.find(id: TokenID(TokenListStub.C_Address))!
    }
    var itemD: TokenListItem {
        return tokenListItemRepository.find(id: TokenID(TokenListStub.D_Address))!
    }
    var allItems: [TokenListItem] {
        return tokenListItemRepository.all()
    }

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: tokenListService, for: TokenListDomainService.self)
        DomainRegistry.put(service: tokenListItemRepository, for: TokenListItemRepository.self)
        DomainRegistry.put(service: publisher, for: EventPublisher.self)
        merger = TokenListMerger()
    }

    func test_whenMerging_thenEmmitsEvent() throws {
        publisher.expectToPublish(TokenListMerged.self)
        merger.mergeStoredTokenItems(with: try tokenListService.items())
        XCTAssertTrue(publisher.publishedWhatWasExpected())
    }

    func test_correctMergingOfStatuses() throws {
        // Notation: A+ whitelisted; B default; C- blacklisted
        // Notation: A_, B_ and etc. tokens have the same address

        XCTAssertEqual(allItems.count, 0)

        // From Service: A+, B, C, D+
        // Expected Result after merge: A+, B, C, D+
        tokenListService.json = TokenListStub.json
        merger.mergeStoredTokenItems(with: try tokenListService.items())
        XCTAssertEqual(allItems.count, 4)
        assertTokenItem(itemA, .whitelisted, "A", 0)
        assertTokenItem(itemB, .regular, "B")
        assertTokenItem(itemC, .regular, "C")
        assertTokenItem(itemD, .whitelisted, "D", 1)

        // Blacklist token D: D+ --> D-
        let blacklistedD = TokenListItem(token: itemD.token, status: .blacklisted, canPayTransactionFee: false)
        tokenListItemRepository.save(blacklistedD)
        assertTokenItem(itemD, .blacklisted, "D")

        // From Service: A_1+, B_1+, C_1, D_1
        // Expected Result after merge: A_1+, B_1+, C_1, D_1-
        tokenListService.json = TokenListStub.json1
        merger.mergeStoredTokenItems(with: try tokenListService.items())
        XCTAssertEqual(allItems.count, 4)
        assertTokenItem(itemA, .whitelisted, "A_1", 0)
        assertTokenItem(itemB, .whitelisted, "B_1", 1)
        assertTokenItem(itemC, .regular, "C_1")
        assertTokenItem(itemD, .blacklisted, "D_1")

        // From Service: A_1, B_1, C_1+, D_2+
        // Expected Result after merge: A_1+, B_1+, C_1+, D_2-
        tokenListService.json = TokenListStub.json2
        merger.mergeStoredTokenItems(with: try tokenListService.items())
        XCTAssertEqual(allItems.count, 4)
        assertTokenItem(itemA, .whitelisted, "A_1", 0)
        assertTokenItem(itemB, .whitelisted, "B_1", 1)
        assertTokenItem(itemC, .whitelisted, "C_1", 2)
        assertTokenItem(itemD, .blacklisted, "D_2")
    }

    func test_correctDeletingOfStoredItems() throws {
        XCTAssertEqual(allItems.count, 0)
        tokenListService.json = TokenListStub.json
        // Expected Result after merge: A+, B, C, D+
        merger.mergeStoredTokenItems(with: try tokenListService.items())
        XCTAssertEqual(allItems.count, 4)

        let blacklistedB = itemB
        blacklistedB.blacklist()
        tokenListItemRepository.save(blacklistedB)
        assertTokenItem(itemB, .blacklisted, "B")

        // Before merge: A+, B-, C, D+
        tokenListService.json = TokenListStub.emptyJson
        // Expected Result after merge: A+, D+
        merger.mergeStoredTokenItems(with: try tokenListService.items())
        XCTAssertEqual(allItems.count, 2)
        assertTokenItem(itemA, .whitelisted, "A", 0)
        assertTokenItem(itemD, .whitelisted, "D", 1)
    }

    func test_whenUpdatingWhitelistedTokenItem_thenItKeepsItsSortingNumber() throws {
        XCTAssertEqual(allItems.count, 0)
        tokenListService.json = TokenListStub.json
        // Expected Result after merge: A+, B, C, D+
        merger.mergeStoredTokenItems(with: try tokenListService.items())
        XCTAssertEqual(allItems.count, 4)

        let whitelistedA = itemA
        whitelistedA.updateSortingId(with: 2)
        tokenListItemRepository.save(whitelistedA)
        let whitelistedD = itemD
        whitelistedD.updateSortingId(with: 1)
        tokenListItemRepository.save(whitelistedD)

        tokenListService.json = TokenListStub.json1
        merger.mergeStoredTokenItems(with: try tokenListService.items())
        XCTAssertEqual(allItems.count, 4)
        assertTokenItem(itemA, .whitelisted, "A_1", 2)
        assertTokenItem(itemD, .whitelisted, "D_1", 1)
    }

    func test_canPayTransactionFeeUpdates() throws {
        XCTAssertEqual(allItems.count, 0)
        tokenListService.json = TokenListStub.json
        merger.mergeStoredTokenItems(with: try tokenListService.items())
        XCTAssertTrue(itemA.canPayTransactionFee)
        XCTAssertFalse(itemB.canPayTransactionFee)
        XCTAssertTrue(itemD.canPayTransactionFee)

        tokenListService.json = TokenListStub.json1
        merger.mergeStoredTokenItems(with: try tokenListService.items())
        XCTAssertTrue(itemA.canPayTransactionFee)
        XCTAssertTrue(itemB.canPayTransactionFee)
        XCTAssertFalse(itemD.canPayTransactionFee)
    }

}

private extension TokenListMergerTests {

    func assertTokenItem(_ tokenListItem: TokenListItem,
                         _ status: TokenListItem.TokenListItemStatus,
                         _ code: String,
                         _ sortingId: Int? = nil,
                         _ line: UInt = #line) {
        XCTAssertEqual(tokenListItem.status, status, line: line)
        XCTAssertEqual(tokenListItem.token.code, code, line: line)
        XCTAssertEqual(tokenListItem.sortingId, sortingId, line: line)
    }

}

fileprivate struct TokenListStub {

    static let A_Address = "0x975be7f72cea31fd83d0cb2a197f9136f38696b7"
    static let B_Address = "0xb3a4bc89d8517e0e2c9b66703d09d3029ffa1e6d"
    static let C_Address = "0x5f92161588c6178130ede8cbdc181acec66a9731"
    static let D_Address = "0xb63d06025d580a94d59801f2513f5d309c079559"

    static let emptyJson = "{\"results\": []}"

    static let json = """
{
    "results": [
        {
            "address": "0x975be7f72cea31fd83d0cb2a197f9136f38696b7",
            "name": "A+ Token",
            "symbol": "A",
            "decimals": 4,
            "logoUri": "https://test.com/A_Token.png",
            "default": true,
            "gas": true
        },
        {
            "address": "0xb3a4bc89d8517e0e2c9b66703d09d3029ffa1e6d",
            "name": "B Token",
            "symbol": "B",
            "decimals": 4,
            "logoUri": "https://test.com/B_Token.png",
            "default": false,
            "gas": false
        },
        {
            "address": "0x5f92161588c6178130ede8cbdc181acec66a9731",
            "name": "C Token",
            "symbol": "C",
            "decimals": 4,
            "logoUri": "https://test.com/C_Token.png",
            "default": false,
            "gas": false
        },
        {
            "address": "0xb63d06025d580a94d59801f2513f5d309c079559",
            "name": "D+ Token",
            "symbol": "D",
            "decimals": 4,
            "logoUri": "https://test.com/D_Token.png",
            "default": true,
            "gas": true
        }
    ]
}
"""

    static let json1 = """
{
    "results": [
        {
            "address": "0x975be7f72cea31fd83d0cb2a197f9136f38696b7",
            "name": "A_1+ Token",
            "symbol": "A_1",
            "decimals": 4,
            "logoUri": "https://test.com/A_Token.png",
            "default": true,
            "gas": true
        },
        {
            "address": "0xb3a4bc89d8517e0e2c9b66703d09d3029ffa1e6d",
            "name": "B_1+ Token",
            "symbol": "B_1",
            "decimals": 4,
            "logoUri": "https://test.com/B_Token.png",
            "default": true,
            "gas": true
        },
        {
            "address": "0x5f92161588c6178130ede8cbdc181acec66a9731",
            "name": "C_1 Token",
            "symbol": "C_1",
            "decimals": 4,
            "logoUri": "https://test.com/C_Token.png",
            "default": false,
            "gas": false
        },
        {
            "address": "0xb63d06025d580a94d59801f2513f5d309c079559",
            "name": "D_1 Token",
            "symbol": "D_1",
            "decimals": 4,
            "logoUri": "https://test.com/D_Token.png",
            "default": false,
            "gas": false
        }
    ]
}
"""

    static let json2 = """
{
    "results": [
        {
            "address": "0x975be7f72cea31fd83d0cb2a197f9136f38696b7",
            "name": "A_1 Token",
            "symbol": "A_1",
            "decimals": 4,
            "logoUri": "https://test.com/A_Token.png",
            "default": false,
            "gas": false
        },
        {
            "address": "0xb3a4bc89d8517e0e2c9b66703d09d3029ffa1e6d",
            "name": "B_1 Token",
            "symbol": "B_1",
            "decimals": 4,
            "logoUri": "https://test.com/B_Token.png",
            "default": false,
            "gas": false
        },
        {
            "address": "0x5f92161588c6178130ede8cbdc181acec66a9731",
            "name": "C_1+ Token",
            "symbol": "C_1",
            "decimals": 4,
            "logoUri": "https://test.com/C_Token.png",
            "default": true,
            "gas": true
        },
        {
            "address": "0xb63d06025d580a94d59801f2513f5d309c079559",
            "name": "D_2+ Token",
            "symbol": "D_2",
            "decimals": 4,
            "logoUri": "https://test.com/D_Token.png",
            "default": true,
            "gas": true
        }
    ]
}
"""
}
