extension Integer {
    public init<T: Swift.BinaryInteger>(_ value: T) {
        var magnitude = value.magnitude
        var words: [UInt32] = []
        while magnitude != 0 {
            words.append(UInt32(truncatingIfNeeded: magnitude))
            magnitude >>= 32
        }
        self.init(storage: Natural(words: words), negative: value < 0)
    }


    public func exactly<T: Swift.FixedWidthInteger>(_ type: T.Type) -> T? {

        T(description, radix: 10)
    }
}
