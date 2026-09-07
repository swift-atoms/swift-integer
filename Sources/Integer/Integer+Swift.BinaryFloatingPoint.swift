extension Integer {


    public func approximation<Scalar: BinaryFloatingPoint>(as type: Scalar.Type) -> Scalar {
        let value = scaledApproximation(as: type)
        return Scalar(sign: isNegative ? .minus : .plus,
            exponent: Scalar.Exponent(clamping: value.exponent),
            significand: value.significand.magnitude)
    }



    public func scaledApproximation<Scalar: BinaryFloatingPoint>(
        as type: Scalar.Type
    ) -> (significand: Scalar, exponent: Int) {
        guard let top = storage.words.last else { return (0, 0) }
        let width = storage.words.count * 32 - top.leadingZeroBitCount
        let precision = Scalar.significandBitCount + 1
        let retained = min(width, precision)
        let last = width - retained
        func bit(at index: Int) -> Bool {
            storage.words[index / 32] & (UInt32(1) << (index % 32)) != 0
        }
        var significand: Scalar = 0
        var weight: Scalar = 1
        for index in (last..<width).reversed() {
            if bit(at: index) { significand += weight }
            weight /= 2
        }
        if last > 0, bit(at: last - 1) {
            let guardIndex = last - 1
            let wordIndex = guardIndex / 32
            let mask = (UInt32(1) << (guardIndex % 32)) - 1
            let sticky = storage.words[..<wordIndex].contains { $0 != 0 }
                || storage.words[wordIndex] & mask != 0
            if sticky || bit(at: last) { significand = significand.nextUp }
        }
        return (isNegative ? -significand : significand, width - 1)
    }
}
