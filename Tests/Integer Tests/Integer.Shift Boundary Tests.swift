import Integer
import Testing

@Suite struct `Integer shifts cover extreme counts and signed boundaries` {
    @Test func `Signed byte shifts agree with a wider division oracle`() throws {
        let rules: [(Rounding, FloatingPointRoundingRule)] = [
            (.down, .down), (.up, .up), (.zero, .towardZero), (.away, .awayFromZero),
            (.even, .toNearestOrEven), (.nearest(.away), .toNearestOrAwayFromZero),
        ]
        for value in -128...127 {
            for count in 0...12 {
                for (rule, standard) in rules {
                    let expected = Int((Double(value) / Double(1 << count)).rounded(standard))
                    #expect(try Int8(value).shifted.right(by: count, rounding: rule) == Int8(expected))
                }
            }
        }
    }

    @Test func `Exact shifts reject lost bits and extreme counts remain defined`() throws {
        #expect(throws: Rounding.Error.inexact) { try Int8(-3).shifted.right(by: 1, rounding: .exact) }
        #expect(try Int8(-3).shifted.right(by: Int.max, rounding: .even) == 0)
        #expect(try Int8(-3).shifted.right(by: Int.max, rounding: .down) == -1)
        #expect(try UInt8(255).shifted.right(by: UInt.max, rounding: .up) == 1)
        #expect(try Int8(1).shifted.right(by: Int.min) == 0)
    }
}
