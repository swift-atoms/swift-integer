extension Integer: Swift.ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Swift.StaticBigInt) {
        let negative = value.signum() < 0
        var words: [UInt32] = []
        for index in 0..<((value.bitWidth + UInt.bitWidth - 1) / UInt.bitWidth) {
            let word = negative ? ~value[index] : value[index]
            for offset in stride(from: 0, to: UInt.bitWidth, by: 32) {
                words.append(UInt32(truncatingIfNeeded: word >> offset))
            }
        }
        var magnitude = Natural(words: words)
        if negative { magnitude = magnitude + Natural(1) }
        self.init(storage: magnitude, negative: negative)
    }
}
