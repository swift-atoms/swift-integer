extension Integer {
    public var approximation: Double { approximation(as: Double.self) }


    public var scaledApproximation: (significand: Double, exponent: Int) {
        scaledApproximation(as: Double.self)
    }
}
