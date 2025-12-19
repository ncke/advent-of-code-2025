import Foundation

// MARK: - Solution

let input = Input.parseInput(Input.example)
var grid = Grid(content: input)

// For part 1, find the number of accessible rolls in the grid.
let part1 = findAccessibleRolls(in: grid).count
print("Part 1:", part1)

// Part 2. Successively remove all available rolls from the grid until
// none remain accessible.

var rollsRemoved = 0
var accessibleCount = part1

while accessibleCount > 0 {
    // Find and remove accessible rolls.
    let accessibleRolls = findAccessibleRolls(in: grid)
    for location in accessibleRolls { grid[location] = "." }

    // Update totals.
    rollsRemoved += accessibleRolls.count
    accessibleCount = accessibleRolls.count
}

print("Part 2:", rollsRemoved)

// MARK: - Forklift Access Logic

/// Returns the grid location of all rolls accessible by a forklift
/// because it has less than four neighbouring rolls.
func findAccessibleRolls(in grid: Grid) -> [Location] {
    grid
    .locationsWhere { char in char == "@" }
    .filter { location in
        let neighbourLocations = grid.neighbours(of: location)
        let neighbourRolls = neighbourLocations.filter {
            location in grid[location] == "@"
        }

        return neighbourRolls.count < 4
    }
}

// MARK: - Grid Structure

typealias Location = (Int, Int)

struct Grid {
    private(set) var content: [String]
    let size: (Int, Int)

    init(content: [String]) {
        self.content = content
        self.size = (content[0].count, content.count)
    }

    /// Get or set the character at a grid location.
    subscript(_ location: Location) -> Character {
        get {
            let (x, y) = location
            let line = content[y]
            let char = line[line.index(line.startIndex, offsetBy: x)]
            return char
        }
        set {
            let (x, y) = location
            let line = content[y]
            let pre = line.prefix(x)
            let post = line.dropFirst(x + 1)
            content[y] = String(pre) + String(newValue) + String(post)
        }
    }

    /// Returns an array of all locations in the grid for which the
    /// given `predicate` returned `true`.
    func locationsWhere(_ predicate: (Character) -> Bool) -> [Location] {
        var matched: [Location] = []
        let (width, height) = size
        for y in 0..<height {
            for x in 0..<width {
                if predicate(self[(x, y)]) { matched.append((x, y)) }
            }
        }

        return matched
    }

    private static let neighbourOffsets = [
        (-1,  1), (0,  1), (1,  1),
        (-1,  0),          (1,  0),
        (-1, -1), (0, -1), (1, -1)
    ]

    /// Returns the grid location of all neighbours of the given `location`.
    /// Note: only returns locations that are inside the grid bounds.
    func neighbours(of location: Location) -> [Location] {
        var legals: [Location] = []
        let (width, height) = size
        let (x, y) = location

        for offset in Self.neighbourOffsets {
            let (ox, oy) = offset
            let (nx, ny) = (x + ox, y + oy)

            if nx >= 0, nx < width, ny >= 0, ny < height {
                legals.append((nx, ny))
            }
        }

        return legals
    }

}

// MARK: - Input

struct Input {

    static func parseInput(_ string: String) -> [String] {
        string.components(separatedBy: "\n")
    }

    static let example = """
..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@.
"""

}
