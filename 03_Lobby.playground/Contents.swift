import Foundation

// MARK: - Solution

let input = Input.parseInput(Input.example)

let part1 = input
    .map { bank in maximiseJoltage(in: bank, batteryCount: 2) }
    .reduce(0, +)

print("Part 1:", part1)

let part2 = input
    .map { bank in maximiseJoltage(in: bank, batteryCount: 12) }
    .reduce(0, +)

print("Part 2:", part2)

// MARK: - Joltage Logic

/// Find the highest joltage available from the given `bank` formed by
/// turning on `batteryCount` number of batteries.
func maximiseJoltage(in bank: String, batteryCount: Int) -> Int {
    var digits = [Int]()
    var start = 0

    for n in 0..<batteryCount {
        // Calculate the remaining number of batteries still to be allocated.
        // We need to ensure that we select from a range, after which there
        // must be sufficient remaining batteries to allow the remainder to
        // be populated.
        let remaining = batteryCount - 1 - n
        let finish = bank.count - remaining - 1

        // Find the index of the highest battery in the range, and populate
        // into the digits.
        let index = indexOfHighestBattery(in: bank, range: start...finish)
        let battery = bank.digitAt(index)
        digits.append(battery)

        // Further batteries will be selected right-ward from this highest
        // battery.
        start = index + 1
    }

    return joltageFromDigits(digits)
}

/// Returns the index in `bank` of the highest battery value inside the
/// given `range`.
func indexOfHighestBattery(in bank: String, range: ClosedRange<Int>) -> Int {
    var index = range.lowerBound
    var battery = bank.digitAt(index)
    for n in range {
        if bank.digitAt(n) > battery {
            index = n
            battery = bank.digitAt(n)
        }
    }

    return index
}

/// Given an array of battery values, returns the joltage produced.
func joltageFromDigits(_ digits: [Int]) -> Int {
    var joltage = 0
    for digit in digits { joltage = 10 * joltage + digit }

    return joltage
}

// MARK: - String Helpers

extension String {

    func digitAt(_ offset: Int) -> Int {
        let digit = self[self.index(self.startIndex, offsetBy: offset)]
        return Int(digit.asciiValue! - 48)
    }

    func digitsFrom(_ offset: Int, length: Int) -> [Int] {
        (0..<length).reduce(into: [Int]()) { partial, idx in
            partial.append(digitAt(offset + idx))
        }
    }

}

// MARK: - Input

struct Input {

    static func parseInput(_ string: String) -> [String] {
        string.components(separatedBy: "\n")
    }

    static let example = """
987654321111111
811111111111119
234234234234278
818181911112111
"""

}
