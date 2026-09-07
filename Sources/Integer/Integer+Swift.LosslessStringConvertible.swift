extension Integer: Swift.LosslessStringConvertible {

    public init?(_ description: String) {
        var digits = description.utf8[...]
        let negative = digits.first == 45
        if negative || digits.first == 43 { digits = digits.dropFirst() }
        guard !digits.isEmpty else { return nil }
        var value = Natural()
        for digit in digits {
            guard (48...57).contains(digit) else { return nil }
            value = value * Natural(10) + Natural(UInt128(digit - 48))
        }
        self.init(storage: value, negative: negative)
    }
}
