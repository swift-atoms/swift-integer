import Testing

import Integer

@Suite struct `Integer divisibility covers signed boundaries` {
    @Test func `Signed minima are widened before taking magnitudes`() {
        #expect(Integer.gcd(Int8.min, 2) == 2)
        #expect(Integer.gcd(Int8.min, 0) == 128)
        #expect(Integer.lcm(Int8.min, 3) == 384)
        #expect(Integer.lcm(Int64.min, 3).description == "27670116110564327424")
        #expect(Integer.lcm(Int8.min, 3).exactly(Int8.self) == nil)
    }

    @Test func `The divisibility identity holds across the signed byte domain`() throws {
        for a in -128...127 {
            for b in -12...12 {
                let x = Integer(a), y = Integer(b)
                let gcd = Integer.gcd(Int8(a), Int8(b))
                let lcm = Integer.lcm(Int8(a), Int8(b))
                #expect(gcd * lcm == (x * y).absolute)
                if !gcd.isZero {
                    #expect(try x.quotientAndRemainder(dividingBy: gcd).remainder == .zero)
                    #expect(try y.quotientAndRemainder(dividingBy: gcd).remainder == .zero)
                }
            }
        }
    }
}

@Suite
struct `Integer divisibility finds common factors and multiples` {
    @Suite struct `Integer common factors and multiples obey divisibility identities` {}
    @Suite struct `Integer common factors and multiples normalize signs and zero` {}
    @Suite struct `No integer divisibility integration cases are defined` {}
    @Suite(.serialized) struct `No integer divisibility performance cases are defined` {}
}

extension `Integer divisibility finds common factors and multiples`.`Integer common factors and multiples obey divisibility identities` {
    @Test
    func `GCD of 24 and 36 equals 12`() {
        #expect(Integer.gcd(24, 36) == 12)
    }

    @Test
    func `GCD of coprime numbers equals 1`() {
        #expect(Integer.gcd(17, 13) == 1)
    }

    @Test
    func `The greatest common divisor equals the divisor when one value divides the other`() {
        #expect(Integer.gcd(100, 25) == 25)
    }

    @Test
    func `LCM of 4 and 6 equals 12`() {
        #expect(Integer.lcm(4, 6) == 12)
    }

    @Test
    func `LCM of coprime numbers equals product`() {
        #expect(Integer.lcm(3, 5) == 15)
    }

    @Test
    func `LCM of 12 and 18 equals 36`() {
        #expect(Integer.lcm(12, 18) == 36)
    }
}

extension `Integer divisibility finds common factors and multiples`.`Integer common factors and multiples normalize signs and zero` {
    @Test
    func `GCD with zero returns other value`() {
        #expect(Integer.gcd(0, 5) == 5)
        #expect(Integer.gcd(5, 0) == 5)
        #expect(Integer.gcd(0, 0) == 0)
    }

    @Test
    func `Greatest common divisors use the magnitudes of negative inputs`() {
        #expect(Integer.gcd(-24, 36) == 12)
        #expect(Integer.gcd(24, -36) == 12)
        #expect(Integer.gcd(-24, -36) == 12)
    }

    @Test
    func `LCM with zero returns zero`() {
        #expect(Integer.lcm(0, 5) == 0)
        #expect(Integer.lcm(5, 0) == 0)
    }

    @Test
    func `Least common multiples use the magnitudes of negative inputs`() {
        #expect(Integer.lcm(-4, 6) == 12)
        #expect(Integer.lcm(4, -6) == 12)
    }
}
