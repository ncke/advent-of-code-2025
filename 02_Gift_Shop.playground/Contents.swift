import Foundation

// MARK: - Solution

/// The tricky part of this solution is to obtain a reasonably fast test
/// for repetition in a number. The `isRepeating(_:)` extension on `Int`
/// performs the test mathematically which avoids the need for strings or
/// arrays of digits.

// Obtain the input as an array of ranges to check.
let input = Input.parseInput(Input.example)

// Sum the numbers across all of the ranges with digits that repeat
// exactly twice.
let part1 = input.reduce(0) { partial, range in
    partial + generate(range: range, repeats: 2).reduce(0, +)
}

print("Part 1:", part1)

// Sum the numbers across all of the ranges with digits that repeat
// twice or more.
let part2 = input.reduce(0) { partial, range in
    let maximumRepeats = range.upperBound.lengthInDigits()
    let repeatingNumbers = generate(range: range, repeats: 2...maximumRepeats)
    return partial + repeatingNumbers.reduce(0, +)
}

print("Part 2:", part2)

/// Checks each number in the given `range` to see if it contains a
/// sequence of digits that reoccurs for a number of times in the `repeats`
/// range. Returns the set of such repeating numbers.
func generate(range: ClosedRange<Int>, repeats: ClosedRange<Int>) -> Set<Int> {
    repeats.reduce(Set<Int>()) { partial, reps in
        partial.union(generate(range: range, repeats: reps))
    }
}

/// Checks each number in the given `range` to see if it contains a
/// sequence of digits that reoccurs `repeats` times. Returns the set of
/// such repeating numbers.
func generate(range: ClosedRange<Int>, repeats: Int) -> Set<Int> {
    Set(range.filter { number in number.isRepeating(repeats) })
}

// MARK: - Repetition Logic

extension Int {

    /// Returns `true` for an integer with digits that repeat exactly
    /// the number of times specified by `repeats`, `false` otherwise.
    func isRepeating(_ repeats: Int) -> Bool {
        let length = lengthInDigits()
        guard length >= repeats, length % repeats == 0 else { return false }

        // The `fix` is the leftmost part of the number, the part that will
        // be repeated.
        let tens = Int(pow(10, Double(length / repeats)))
        let fix = self - (tens * (self / tens))

        // Perform the repetition mathematically to construct the number
        // that results from repetition of the `fix`.
        var number = fix
        for _ in 1..<repeats { number = number * tens + fix }

        // Is it the number you first thought of? :)
        return number == self
    }

    /// Returns the number of digits in a positive integer.
    func lengthInDigits() -> Int { Int(log10(Double(self))) + 1 }

}

// MARK: - Input

struct Input {

    static func parseInput(_ string: String) -> [ClosedRange<Int>] {
        string
            .components(separatedBy: ",")
            .map { rangeString in
                let parts = rangeString.components(separatedBy: "-")
                let lower = Int(parts[0])!
                let upper = Int(parts[1])!
                return lower...upper
            }
    }

    static let example = """
11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124
"""

}

