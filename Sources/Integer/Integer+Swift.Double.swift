extension Integer {
    public var approximation: Double { approximation(as: Double.self) }

    /// A finite leading significand and binary scale, even for very large integers.
    public var scaledApproximation: (significand: Double, exponent: Int) {
        scaledApproximation(as: Double.self)
    }
}
