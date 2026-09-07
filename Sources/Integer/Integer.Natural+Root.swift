extension Integer.Natural {
    internal var bitWidth: Int {
        guard let last = words.last else { return 0 }
        return (words.count - 1) * 32 + 32 - last.leadingZeroBitCount
    }
    internal func root(_ degree: Int) -> Self? {
        precondition(degree > 0)
        if self == Self(1) || isZero || degree == 1 { return self }
        guard degree <= bitWidth else { return nil }
        let bits = (bitWidth - 1) / degree + 1
        var highWords = [UInt32](repeating: 0, count: bits / 32 + 1)
        highWords[bits / 32] = UInt32(1) << (bits % 32)
        var low = Self(1)
        var high = Self(words: highWords)
        while low <= high {
            let middle = (low + high).divided(by: Self(2)).quotient
            var value = Self(1)
            for _ in 0..<degree {
                value = value * middle
                if value > self { break }
            }
            if value == self { return middle }
            if value < self { low = middle + Self(1) }
            else { high = middle - Self(1) }
        }
        return nil
    }
}
