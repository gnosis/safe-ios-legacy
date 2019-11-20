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
    }

    private(set) var slots: [Slot] = []

    let optionCount: Int

    init(words: [String], optionCount: Int) {
        self.optionCount = optionCount
        slots = words.enumerated().map {
            Slot(actualWord: SeedWord(index: $0.offset, value: $0.element, style: .filled),
                 enteredWord: nil)
        }
    }

    /// Unknown, "puzzle" words
    var wordOptions: [SeedWord] {
        slots.map { $0.actualWord }.filter { $0.style != .filled }
    }

    /// Current state of the puzzle
    var seedPhrase: [SeedWord] {
        slots.map {
            SeedWord(index: $0.actualWord.index,
                     value: $0.enteredWord?.value ?? $0.actualWord.value,
                     style: $0.actualWord.style)
        }
    }

    /// Whether we have left something to enter or not
    var isAllSlotsEntered: Bool {
        return slots.filter { $0.actualWord.style != .filled }.allSatisfy { $0.enteredWord != nil }
    }

    /// Resets the puzzle state and regenerate options at random
    func reset() {
        for i in (0..<slots.count) {
            slots[i].actualWord.style = .filled
            slots[i].enteredWord = nil
        }
        for i in randomSlotIndices(optionCount) {
            slots[i].actualWord.style = .empty
        }
        updateFocus()
    }

    /// Returns n random slot indeces
    private func randomSlotIndices(_ n: Int) -> [Int] {
        guard n > 0 && n <= slots.count else { return [] }
        var indices = Array(0..<slots.count)
        var result = [Int]()
        for _ in (0..<n) {
            let index = indices.randomElement()!
            indices.removeAll { $0 == index }
            result.append(index)
        }
        assert(result.count == n)
        return result
    }

    private func updateFocus() {
        guard let index = slots.firstIndex(where: { $0.actualWord.style == .empty }) else { return }
        slots[index].actualWord.style = .focused
        assert(slots.filter { $0.actualWord.style == .focused }.count == 1)
    }

    /// Enters a word in a focused slot
    func enter(word: SeedWord) {
        guard let index = slots.firstIndex(where: { $0.actualWord.style == .focused }) else {
            assertionFailure()
            return
        }
        slots[index].actualWord.style = .entered
        slots[index].enteredWord = word
        updateFocus()
    }

    /// Checks wheter all slots are entered and have words matching with actual seed phrase words
    func validate() -> Bool {
        let isValid = slots.filter { $0.actualWord.style != .filled }
            .allSatisfy { $0.actualWord.value == $0.enteredWord?.value }
        for i in (0..<slots.count) {
            guard slots[i].actualWord.style != .filled else { continue }
            if slots[i].actualWord.value == slots[i].enteredWord?.value {
                slots[i].actualWord.style = .filled
            } else {
                slots[i].actualWord.style = .error
            }
        }
        return isValid
    }

}
