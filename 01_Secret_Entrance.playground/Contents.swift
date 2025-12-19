import Combine
import Foundation

// MARK: - Solution

// Get the list of rotations in the given combination.
let rotations = Input.parseInput(string: Input.example)

// The safe dial always begins set to 50.
let initialDialPosition = 50

// Publish a list of sequential positions of the safe dial as a 3-tuple
// of the position before the rotation, the position after the rotation,
// and the rotation distance itself.
let positions = rotations
    .scan((0, initialDialPosition, 0)) { position, distance in
        let (_, after, _) = position
        return (after, rotate(after, distance: distance), distance)
    }

// Part 1. Evaluate the number of times that the dial points to zero
// after a movement has been completed.
let _ = positions
    .map { (before, after, distance) in isZero(position: after) ? 1 : 0 }
    .reduce(0, +)
    .sink { sum in print("Part 1:", sum) }

// Part 2. Evaluate the number of times that the dial pointed to zero,
// whether during the course of a rotation or at the end of a rotation.
let _ = positions
    .map { (before, after, distance) in
        // For each rotation, we visit zero once per complete revolution of
        // the dial (for larger distances). We could then pass zero again
        // when turning the remainder of the distance and, finally, we might
        // end the rotation pointing to zero.
        numberOfRevolutions(distance: distance)
        + (hasPassedZero(before, after, distance: distance) ? 1 : 0)
        + (isZero(position: after) ? 1 : 0)
    }
    .reduce(0, +)
    .sink{ sum in print("Part 2:", sum) }

// MARK: - Safe Dial Logic

/// Returns the new position on the dial after turning through the
/// given distance.
func rotate(_ start: Int, distance: Int) -> Int {
    precondition(start >= 0 && start <= 99)
    precondition(distance != 0)

    let position = (start + distance) % 100
    return position < 0 ? position + 100 : position
}

/// Returns the number of complete revolutions of the dial made during
/// a turn of the given distance. For example: a turn of 250 clicks,
/// involves two complete revolutions (each of 100 clicks).
func numberOfRevolutions(distance: Int) -> Int {
    abs(distance / 100)
}

/// Returns `true` if the dial passed through zero when moving from the
/// `before` position to the `after` position. Note: the definition
/// of passing through zero is strict, a dial leaving zero or arriving at
/// zero does not 'pass' through zero.
func hasPassedZero(_ before: Int, _ after: Int, distance: Int) -> Bool {
    precondition(before >= 0 && before <= 99)
    precondition(after >= 0 && after <= 99)
    precondition(distance != 0)

    func hasPassedZeroClockwise(_ before: Int, _ after: Int) -> Bool {
        // Moving clockwise we have passed through zero if we arrive at
        // a dial position that is smaller than our starting position.
        // For example, if the dial is set to 80 before the rotation and
        // is set to 20 after the rotation, then we moved through zero
        // (and in this example the rotation was R40).
        after < before && after != 0
    }

    func hasPassedZeroAntiClockwise(_ before: Int, _ after: Int) -> Bool {
        // Moving anticlockwise we have passed through zero if we arrive at
        // a dial position that is greater than our starting position.
        // For example, if the dial is set to 15 before the rotation and
        // is set to 90 after the rotation, then we moved through zero
        // (and in this example the rotation was L25).
        after > before && before != 0
    }

    // We use the distance to determine whether we are travelling
    // clockwise or anticlockwise around the dial, and then invoke
    // the corresponding logic.
    return distance > 0
    ? hasPassedZeroClockwise(before, after)
    : hasPassedZeroAntiClockwise(before, after)
}

/// Returns `true` if the position of the safe dial is pointing to zero,
/// `false` otherwise.
func isZero(position: Int) -> Bool {
    position == 0
}

// MARK: - Input

struct Input {

    /// Publishes a stream of safe dial movements derived from the given
    /// input string.
    static func parseInput(string: String) -> AnyPublisher<Int, Never> {
        string
            .components(separatedBy: "\n")
            .map { line in
                let directionCharacter = line.first!
                let distance = Int(line.dropFirst())!
                return directionCharacter == "L" ? -distance : distance
            }
            .publisher
            .eraseToAnyPublisher()
    }

    // Example input.
    static let example = """
L68
L30
R48
L5
R60
L55
L1
L99
R14
L82
"""

}
