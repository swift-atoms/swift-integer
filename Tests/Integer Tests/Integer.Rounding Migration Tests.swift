import Integer
import Testing

@Suite
struct `Integer shifts apply rounding policies` {
    @Suite struct `Integer shifts follow directed nearest exact and odd rounding policies` {}
    @Suite struct `Integer shifts handle large counts unsigned values and generic count types` {}
    @Suite struct `No integer shift rounding integration cases are defined` {}
    @Suite(.serialized) struct `No integer shift rounding performance cases are defined` {}
}

extension `Integer shifts apply rounding policies`.`Integer shifts follow directed nearest exact and odd rounding policies` {
    @Test
    func `shift down matches standard right shift operator`() throws {
        #expect(try 7.shifted.right(by: 1) == 7 >> 1)
        #expect(try 7.shifted.right(by: 2) == 7 >> 2)
        #expect(try (-7).shifted.right(by: 1) == -7 >> 1)
        #expect(try (-7).shifted.right(by: 2) == -7 >> 2)
    }

    @Test
    func `shift by zero returns original value`() throws {
        #expect(try 42.shifted.right(by: 0) == 42)
        #expect(try (-42).shifted.right(by: 0) == -42)
    }

    @Test
    func `negative shift count means left shift`() throws {
        #expect(try 3.shifted.right(by: -1) == 6)
        #expect(try 3.shifted.right(by: -2) == 12)
    }

    @Test
    func `round down floors toward negative infinity`() throws {
        #expect(try 3.shifted.right(by: 1, rounding: .down) == 1)
        #expect(try 7.shifted.right(by: 2, rounding: .down) == 1)
        #expect(try (-3).shifted.right(by: 1, rounding: .down) == -2)
    }

    @Test
    func `round up ceils toward positive infinity`() throws {
        #expect(try 3.shifted.right(by: 1, rounding: .up) == 2)
        #expect(try 7.shifted.right(by: 2, rounding: .up) == 2)
        #expect(try (-3).shifted.right(by: 1, rounding: .up) == -1)
    }

    @Test
    func `round toward zero truncates`() throws {
        #expect(try 3.shifted.right(by: 1, rounding: .zero) == 1)
        #expect(try (-3).shifted.right(by: 1, rounding: .zero) == -1)
    }

    @Test
    func `Integer shifts round discarded fractions away from zero`() throws {
        #expect(try 3.shifted.right(by: 1, rounding: .away) == 2)
        #expect(try (-3).shifted.right(by: 1, rounding: .away) == -2)
    }

    @Test
    func `nearest or even rounds ties to even`() throws {
        #expect(try 3.shifted.right(by: 1, rounding: .even) == 2)
        #expect(try 5.shifted.right(by: 1, rounding: .even) == 2)
        #expect(try 7.shifted.right(by: 1, rounding: .even) == 4)
    }

    @Test
    func `nearest or up rounds ties up`() throws {
        #expect(try 3.shifted.right(by: 1, rounding: .nearest(.up)) == 2)
        #expect(try 5.shifted.right(by: 1, rounding: .nearest(.up)) == 3)
    }

    @Test
    func `nearest or down rounds ties down`() throws {
        #expect(try 3.shifted.right(by: 1, rounding: .nearest(.down)) == 1)
        #expect(try 5.shifted.right(by: 1, rounding: .nearest(.down)) == 2)
    }

    @Test
    func `nearest or away rounds ties away from zero`() throws {
        #expect(try 3.shifted.right(by: 1, rounding: .nearest(.away)) == 2)
        #expect(try (-3).shifted.right(by: 1, rounding: .nearest(.away)) == -2)
    }

    @Test
    func `nearest or zero rounds ties toward zero`() throws {
        #expect(try 3.shifted.right(by: 1, rounding: .nearest(.zero)) == 1)
        #expect(try (-3).shifted.right(by: 1, rounding: .nearest(.zero)) == -1)
    }

    @Test
    func `non-tie values round to nearest`() throws {
        #expect(try 7.shifted.right(by: 2, rounding: .even) == 2)
        #expect(try 7.shifted.right(by: 2, rounding: .nearest(.up)) == 2)
        #expect(try 7.shifted.right(by: 2, rounding: .nearest(.down)) == 2)
    }

    @Test
    func `Inexact integer shifts select an odd result`() throws {
        #expect(try 4.shifted.right(by: 1, rounding: .odd) == 2)
        #expect(try 3.shifted.right(by: 1, rounding: .odd) == 1)
        #expect(try 6.shifted.right(by: 1, rounding: .odd) == 3)
        #expect(try 5.shifted.right(by: 1, rounding: .odd) == 3)
    }

    @Test
    func `exact shift requires no rounding`() throws {
        #expect(try 4.shifted.right(by: 2, rounding: .exact) == 1)
        #expect(try 8.shifted.right(by: 1, rounding: .exact) == 4)
    }
}

extension `Integer shifts apply rounding policies`.`Integer shifts handle large counts unsigned values and generic count types` {
    @Test
    func `Integer shifts handle counts larger than the storage width`() throws {
        let value: Int8 = 127
        #expect(try value.shifted.right(by: 100, rounding: .down) == 0)
        #expect(try value.shifted.right(by: 100, rounding: .up) == 1)
    }

    @Test
    func `Unsigned integer shifts follow the selected rounding policy`() throws {
        let value: UInt8 = 7
        #expect(try value.shifted.right(by: 1, rounding: .down) == 3)
        #expect(try value.shifted.right(by: 1, rounding: .up) == 4)
    }

    @Test
    func `Integer shifts accept different integer count types`() throws {
        let value = 7
        let countInt8: Int8 = 1
        let countUInt: UInt = 1
        #expect(try value.shifted.right(by: countInt8) == 3)
        #expect(try value.shifted.right(by: countUInt) == 3)
    }
}
