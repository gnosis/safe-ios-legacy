//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class SeedPhrasePuzzleTests: XCTestCase {

    let words = ["1", "2", "3", "4"]

    func test_puzzleHappyCase() {
        let puzzle = SeedPhrasePuzzle(words: words, puzzleWordCount: 2)

        XCTAssertEqual(puzzle.puzzleWordCount, 2)

        puzzle.reset()
        XCTAssertTrue(puzzle.puzzleWords.map { $0.value }.allSatisfy { words.contains($0) },
                      String(describing: puzzle.puzzleWords))

        let answer = puzzle.puzzleWords
        XCTAssertEqual(answer.count, 2)
        XCTAssertEqual(puzzle.seedPhrase.first { $0.value == answer[0].value }?.style, .focused)
        XCTAssertEqual(puzzle.seedPhrase.first { $0.value == answer[1].value }?.style, .empty)

        puzzle.enter(word: answer[0])
        XCTAssertEqual(puzzle.seedPhrase.first { $0.value == answer[0].value }?.style, .entered)
        XCTAssertEqual(puzzle.seedPhrase.first { $0.value == answer[1].value }?.style, .focused)

        puzzle.enter(word: answer[1])

        XCTAssertEqual(puzzle.seedPhrase.first { $0.value == answer[0].value }?.style, .entered)
        XCTAssertEqual(puzzle.seedPhrase.first { $0.value == answer[1].value }?.style, .entered)

        XCTAssertTrue(puzzle.isAllSlotsEntered)

        XCTAssertTrue(puzzle.validate())
        XCTAssertEqual(puzzle.seedPhrase.first { $0.value == answer[0].value }?.style, .filled)
        XCTAssertEqual(puzzle.seedPhrase.first { $0.value == answer[1].value }?.style, .filled)
    }

    func test_errorCase() {
        let puzzle = SeedPhrasePuzzle(words: words, puzzleWordCount: 2)
        puzzle.reset()
        let answer = puzzle.puzzleWords
        puzzle.enter(word: answer[1])
        puzzle.enter(word: answer[0])
        XCTAssertFalse(puzzle.validate())
        XCTAssertEqual(puzzle.seedPhrase.first { $0.value == answer[1].value }?.style, .error)
        XCTAssertEqual(puzzle.seedPhrase.first { $0.value == answer[0].value }?.style, .error)

        puzzle.reset()
        XCTAssertTrue(puzzle.seedPhrase.allSatisfy { $0.style != .error })
    }

}
