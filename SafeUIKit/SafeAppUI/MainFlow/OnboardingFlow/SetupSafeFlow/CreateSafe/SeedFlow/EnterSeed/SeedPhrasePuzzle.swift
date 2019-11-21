//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Model of the EnterSeed screen implementing the seed phrase puzzle:
/// the user needs to correctly enter N words out of the M seed phrase words.
///
/// The general puzzle mechanism is as follows:
///
/// 1. N words selected at random to be unknown words for the user. First of them is highlighted (focused).
/// 2. User enters 4 words, one by one, into the open slots. Every time the word entered, next empty slot is focused.
/// 3. User validates the entries. If all words match original phrase, then the puzzle is solved, we're done.
/// 4. Otherwise, non-matching words marked as errors. User can reset the puzzle now and try again from step #1.
///
class SeedPhrasePuzzle {

    struct Slot {
        var actualWord: SeedWord
        var enteredWord: SeedWord?

        var actualValue: String { actualWord.value }
        var enteredValue: String? { enteredWord?.value }

        var style: SeedWordStyle {
            get { actualWord.style }
            set { actualWord.style = newValue }
        }

        init(index: Int, value: String) {
            actualWord = SeedWord(index: index, value: value, style: .filled)
            enteredWord = nil
        }

    }

    private var slots: [Slot] = []

    let puzzleWordCount: Int

    init(words: [String], puzzleWordCount: Int) {
        self.puzzleWordCount = puzzleWordCount
        slots = words.enumerated().map { Slot(index: $0.offset, value: $0.element) }
    }

    /// Unknown, "puzzle" words
    var puzzleWords: [SeedWord] {
        puzzleSlots.map { $0.actualWord }
    }

    /// Current state of the puzzle
    var seedPhrase: [SeedWord] {
        slots.map { SeedWord(index: $0.actualWord.index, value: $0.enteredValue ?? $0.actualValue, style: $0.style) }
    }

    /// Whether we have left something to enter or not
    var isAllSlotsEntered: Bool {
        puzzleSlots.allSatisfy { $0.enteredValue != nil }
    }

    private var puzzleSlots: [Slot] {
        slots.filter { $0.style != .filled }
    }

    /// Resets the puzzle state and regenerate options at random
    func reset() {
        for i in (0..<slots.count) {
            slots[i].style = .filled
            slots[i].enteredWord = nil

        }
        for i in randomSlotIndices(puzzleWordCount) {
            slots[i].style = .empty
        }
        updateFocus()
    }

    /// Returns n random slot indeces
    private func randomSlotIndices(_ n: Int) -> [Int] {
        guard n > 0 && n <= slots.count else { return [] }
        return Array(Array(0..<slots.count).shuffled().prefix(n))
    }

    private func updateFocus() {
        guard let index = slots.firstIndex(where: { $0.style == .empty }) else { return }
        slots[index].style = .focused
        assert(slots.filter { $0.style == .focused }.count == 1)
    }

    /// Enters a word in a focused slot
    func enter(word: SeedWord) {
        guard let index = slots.firstIndex(where: { $0.style == .focused }) else {
            assertionFailure()
            return
        }
        slots[index].enteredWord = word
        slots[index].style = .entered
        updateFocus()
    }

    /// Checks wheter all slots are entered and have words matching with actual seed phrase words
    func validate() -> Bool {
        let isValid = puzzleSlots.allSatisfy { $0.actualValue == $0.enteredValue }
        for i in (0..<slots.count) {
            guard slots[i].style != .filled else { continue }
            if slots[i].actualValue == slots[i].enteredValue {
                slots[i].style = .filled
            } else {
                slots[i].style = .error
            }
        }
        return isValid
    }

}
