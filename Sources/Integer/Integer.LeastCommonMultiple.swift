extension Integer {


    public static func lcm(_ lhs: Self, _ rhs: Self) -> Self {
        guard !lhs.isZero, !rhs.isZero else { return .zero }
        let divisor = gcd(lhs, rhs)
        let quotient = lhs.storage.divided(by: divisor.storage).quotient
        return Self(storage: quotient * rhs.storage, negative: false)
    }


    public static func gcd<T: Swift.BinaryInteger>(_ lhs: T, _ rhs: T) -> Self {
        gcd(Self(lhs), Self(rhs))
    }


    public static func lcm<T: Swift.BinaryInteger>(_ lhs: T, _ rhs: T) -> Self {
        lcm(Self(lhs), Self(rhs))
    }
}
