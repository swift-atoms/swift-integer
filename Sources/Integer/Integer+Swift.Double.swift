extension Integer {
    public var approximation: Double {
        let value = storage.scaledApproximation
        let result = Double(sign: .plus, exponent: value.exponent, significand: value.significand)
        return isNegative ? -result : result
    }
    /// A finite leading significand and binary scale, even for very large integers.
    public var scaledApproximation: (significand: Double, exponent: Int) {
        let value = storage.scaledApproximation
        return (isNegative ? -value.significand : value.significand, value.exponent)
    }
}
