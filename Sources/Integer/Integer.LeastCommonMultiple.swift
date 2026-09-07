extension Integer {
    /// The nonnegative least common multiple. Either zero operand gives zero.
    /// The result is exact even when it exceeds both operands' machine storage.
    public static func lcm(_ lhs: Self, _ rhs: Self) -> Self {
        guard !lhs.isZero, !rhs.isZero else { return .zero }
        let divisor = gcd(lhs, rhs)
        let quotient = lhs.storage.divided(by: divisor.storage).quotient
        return Self(storage: quotient * rhs.storage, negative: false)
    }

    /// Computes a nonnegative GCD without narrowing signed minimum magnitudes.
    public static func gcd<T: Swift.BinaryInteger>(_ lhs: T, _ rhs: T) -> Self {
        gcd(Self(lhs), Self(rhs))
    }

    /// Computes an exact LCM of machine integers; narrowing is a separate conversion.
    public static func lcm<T: Swift.BinaryInteger>(_ lhs: T, _ rhs: T) -> Self {
        lcm(Self(lhs), Self(rhs))
    }
}
