extension Integer {
    public static prefix func - (value: Self) -> Self {
        Self(storage: value.storage, negative: !value.isNegative)
    }

    public static func + (lhs: Self, rhs: Self) -> Self {
        if lhs.isNegative == rhs.isNegative {
            return Self(storage: lhs.storage + rhs.storage, negative: lhs.isNegative)
        }
        return lhs.storage >= rhs.storage
            ? Self(storage: lhs.storage - rhs.storage, negative: lhs.isNegative)
            : Self(storage: rhs.storage - lhs.storage, negative: rhs.isNegative)
    }
    public static func - (lhs: Self, rhs: Self) -> Self { lhs + (-rhs) }
    public static func * (lhs: Self, rhs: Self) -> Self {
        Self(storage: lhs.storage * rhs.storage, negative: lhs.isNegative != rhs.isNegative)
    }
    public static func += (lhs: inout Self, rhs: Self) { lhs = lhs + rhs }
    public static func -= (lhs: inout Self, rhs: Self) { lhs = lhs - rhs }
    public static func *= (lhs: inout Self, rhs: Self) { lhs = lhs * rhs }

    /// Truncates toward zero. The remainder has the dividend's sign.
    public func quotientAndRemainder(dividingBy divisor: Self) throws(Error) -> (quotient: Self, remainder: Self) {
        guard !divisor.isZero else { throw .zeroDivisor }
        let result = storage.divided(by: divisor.storage)
        return (
            Self(storage: result.quotient, negative: isNegative != divisor.isNegative),
            Self(storage: result.remainder, negative: isNegative)
        )
    }

    public static func gcd(_ lhs: Self, _ rhs: Self) -> Self {
        Self(storage: Natural.gcd(lhs.storage, rhs.storage), negative: false)
    }

    /// Returns an integer root only when the root exists and is exact.
    public func root(_ degree: Int) -> Self? {
        guard degree > 0, !isNegative || degree % 2 == 1,
            let root = storage.root(degree) else { return nil }
        return Self(storage: root, negative: isNegative)
    }
}
