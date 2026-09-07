import Integer
import Testing

@Suite struct `Integer conversion rounds in the requested floating point format` {
    @Test func `Signed short integers agree with Swift conversions`() {
        for value in Int(Int16.min)...Int(Int16.max) {
            let integer = Integer(value)
            #expect(integer.approximation(as: Float16.self) == Float16(value))
            #expect(integer.approximation(as: Float.self) == Float(value))
            #expect(integer.approximation(as: Double.self) == Double(value))
        }
    }

    @Test func `Guard and sticky bits distinguish halfway values`() throws {
        let base = powerOfTwo(100)
        let half = powerOfTwo(76)
        let lower = Float(sign: .plus, exponent: 100, significand: 1)
        #expect((base + half).approximation(as: Float.self) == lower)
        #expect((base + half + 1).approximation(as: Float.self) == lower.nextUp)
        #expect((base + half - 1).approximation(as: Float.self) == lower)
        #expect((base + half * 3).approximation(as: Float.self) == lower.nextUp.nextUp)
        #expect((-(base + half + 1)).approximation(as: Float.self) == -lower.nextUp)
    }

    @Test func `Huge integers retain a finite scaled representation`() {
        let huge = powerOfTwo(4096)
        let scaled = huge.scaledApproximation(as: Float16.self)
        #expect(scaled.significand == 1 && scaled.exponent == 4096)
        #expect(huge.approximation(as: Float16.self) == .infinity)
        #expect((-huge).approximation(as: Double.self) == -.infinity)
        #expect(Integer.zero.approximation(as: Float.self).sign == .plus)
    }
}

private func powerOfTwo(_ exponent: Int) -> Integer {
    (0..<exponent).reduce(Integer.one) { value, _ in value * 2 }
}
