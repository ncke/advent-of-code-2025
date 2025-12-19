import Foundation

// MARK: - Part 1

let input = Input.parseInput(Input.example)
let (freshRanges, ingredients) = input

// Find all ingredients that appear in a fresh range. Count the number.

let part1 = ingredients.filter { ingredient in
    freshRanges.contains { range in range.contains(ingredient) }
}.count

print("Part 1:", part1)

// MARK: - Part 2

// The ranges can be quite large so we want to avoid explicit enumeration of
// their members. We can progressively assimilate the ranges to so that we
// have a set of ranges that don't overlap.

var working = Set<ClosedRange<Int>>()

@MainActor
func assimilateRange(_ range: ClosedRange<Int>) {
    let matching = working.filter { existing in range.overlaps(existing) }
    guard !matching.isEmpty else {
        // No overlap, add this as a new range.
        working.insert(range)
        return
    }

    // We assimilate by finding the new lowerbound and upperbound and
    // replacing the matched ranges with the new range that merges the
    // overlaps. Representing the working list of ranges as a set gives
    // us a convenient way to remove matches without worrying about
    // indices and so on.
    let assimilation = [range] + matching
    let lb = assimilation.map { range in range.lowerBound }.min()!
    let ub = assimilation.map { range in range.upperBound }.max()!
    for match in matching { working.remove(match) }
    working.insert(lb...ub)
}

// Assimilate all of the ranges into the `working` set.
freshRanges.forEach { range in assimilateRange(range) }

// Now that our `working` set of ranges has no overlaps, we can sum the
// `count` of each range to get the number of fresh ingredients.
let part2 = working.map { range in range.count }.reduce(0, +)

print("Part 2:", part2)

// MARK: - Input

struct Input {

    static func parseInput(_ string: String) -> ([ClosedRange<Int>], [Int]) {
        string
            .components(separatedBy: "\n")
            .reduce(([ClosedRange<Int>](), [Int]())) { partial, line in
                var (ranges, ingredients) = partial
                if line.contains(/-/) {
                    let parts = line.components(separatedBy: "-")
                    let lb = Int(parts[0])!
                    let ub = Int(parts[1])!
                    ranges.append(lb...ub)
                } else if let ingredient = Int(line) {
                    ingredients.append(ingredient)
                }

                return (ranges, ingredients)
            }
    }

    static let example = """
3-5
10-14
16-20
12-18

1
5
8
11
17
32
"""

}
