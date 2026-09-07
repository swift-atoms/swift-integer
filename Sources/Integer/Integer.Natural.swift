extension Integer {
    internal struct Natural: Hashable, Sendable, Comparable {
        internal var words: [UInt32]

        internal init(_ value: UInt128 = 0) {
            var value = value
            var words: [UInt32] = []
            while value != 0 {
                words.append(UInt32(truncatingIfNeeded: value))
                value >>= 32
            }
            self.words = words
        }

        internal init(words: [UInt32]) {
            self.words = words
            while self.words.last == 0 { self.words.removeLast() }
        }

        internal var isZero: Bool { words.isEmpty }

        internal static func < (lhs: Self, rhs: Self) -> Bool {
            if lhs.words.count != rhs.words.count { return lhs.words.count < rhs.words.count }
            for (left, right) in zip(lhs.words.reversed(), rhs.words.reversed()) {
                if left != right { return left < right }
            }
            return false
        }

        internal static func + (lhs: Self, rhs: Self) -> Self {
            var words: [UInt32] = []
            var carry: UInt64 = 0
            for index in 0..<max(lhs.words.count, rhs.words.count) {
                let left = index < lhs.words.count ? UInt64(lhs.words[index]) : 0
                let right = index < rhs.words.count ? UInt64(rhs.words[index]) : 0
                let sum = left + right + carry
                words.append(UInt32(truncatingIfNeeded: sum))
                carry = sum >> 32
            }
            if carry != 0 { words.append(UInt32(carry)) }
            return Self(words: words)
        }

        internal static func - (lhs: Self, rhs: Self) -> Self {
            precondition(lhs >= rhs)
            var words = lhs.words
            var borrow: UInt64 = 0
            for index in words.indices {
                let right = (index < rhs.words.count ? UInt64(rhs.words[index]) : 0) + borrow
                let left = UInt64(words[index])
                words[index] = UInt32(truncatingIfNeeded: left &- right)
                borrow = left < right ? 1 : 0
            }
            return Self(words: words)
        }

        internal static func * (lhs: Self, rhs: Self) -> Self {
            if lhs.isZero || rhs.isZero { return Self() }
            var words = [UInt32](repeating: 0, count: lhs.words.count + rhs.words.count)
            for left in lhs.words.indices {
                var carry: UInt64 = 0
                for right in rhs.words.indices {
                    let index = left + right
                    let product = UInt64(lhs.words[left]) * UInt64(rhs.words[right])
                        + UInt64(words[index]) + carry
                    words[index] = UInt32(truncatingIfNeeded: product)
                    carry = product >> 32
                }
                words[left + rhs.words.count] = UInt32(carry)
            }
            return Self(words: words)
        }

        internal func divided(by divisor: Self) -> (quotient: Self, remainder: Self) {
            precondition(!divisor.isZero)
            if self < divisor { return (Self(), self) }
            if divisor.words.count == 1 {
                let divisor = UInt64(divisor.words[0])
                var quotient = words
                var remainder: UInt64 = 0
                for index in words.indices.reversed() {
                    let dividend = (remainder << 32) | UInt64(words[index])
                    quotient[index] = UInt32(dividend / divisor)
                    remainder = dividend % divisor
                }
                return (Self(words: quotient), Self(UInt128(remainder)))
            }
            var quotient = [UInt32](repeating: 0, count: words.count)
            var remainder = Self()
            for index in words.indices.reversed() {
                for bit in (0..<32).reversed() {
                    var carry = (words[index] >> bit) & 1
                    for position in remainder.words.indices {
                        let next = remainder.words[position] >> 31
                        remainder.words[position] = (remainder.words[position] << 1) | carry
                        carry = next
                    }
                    if carry != 0 { remainder.words.append(carry) }
                    if remainder >= divisor {
                        remainder = remainder - divisor
                        quotient[index] |= UInt32(1) << bit
                    }
                }
            }
            return (Self(words: quotient), remainder)
        }

        internal static func gcd(_ lhs: Self, _ rhs: Self) -> Self {
            var left = lhs
            var right = rhs
            while !right.isZero {
                (left, right) = (right, left.divided(by: right).remainder)
            }
            return left
        }

        internal var decimal: String {
            if isZero { return "0" }
            var value = self
            var digits: [String] = []
            while !value.isZero {
                let result = value.divided(by: Self(1_000_000_000))
                let part = String(result.remainder.words.first ?? 0)
                digits.append(result.quotient.isZero ? part : String(repeating: "0", count: 9 - part.count) + part)
                value = result.quotient
            }
            return digits.reversed().joined()
        }

    }
}
