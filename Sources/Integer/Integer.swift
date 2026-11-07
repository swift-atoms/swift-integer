public struct Integer: Hashable, Sendable {
    internal let storage: Natural
    public let isNegative: Bool

    internal init(storage: Natural, negative: Bool) {
        self.storage = storage
        self.isNegative = !storage.isZero && negative
    }
}

extension Integer {
    public static var zero: Self { Self(storage: Natural(), negative: false) }
    public static var one: Self { Self(storage: Natural(1), negative: false) }
    public var isZero: Bool { storage.isZero }
    public var absolute: Self { Self(storage: storage, negative: false) }
    public var isOdd: Bool { (storage.words.first ?? 0) & 1 != 0 }
    public var bitWidth: Int { storage.bitWidth }
}

extension Integer {
    public static prefix func - (value: Self) -> Self {
        Self(storage: value.storage, negative: !value.isNegative)
    }

    public static func + (lhs: Self, rhs: Self) -> Self {
        if lhs.isNegative == rhs.isNegative {
            return Self(storage: lhs.storage + rhs.storage, negative: lhs.isNegative)
        }
        return lhs.storage >= rhs.storage
            ? Self(storage: lhs.storage - rhs.storage, negative: lhs.isNegative)
            : Self(storage: rhs.storage - lhs.storage, negative: rhs.isNegative)
    }
    public static func - (lhs: Self, rhs: Self) -> Self { lhs + (-rhs) }
    public static func * (lhs: Self, rhs: Self) -> Self {
        Self(storage: lhs.storage * rhs.storage, negative: lhs.isNegative != rhs.isNegative)
    }
    public static func += (lhs: inout Self, rhs: Self) { lhs = lhs + rhs }
    public static func -= (lhs: inout Self, rhs: Self) { lhs = lhs - rhs }
    public static func *= (lhs: inout Self, rhs: Self) { lhs = lhs * rhs }

    public func quotientAndRemainder(dividingBy divisor: Self) throws(Error) -> (quotient: Self, remainder: Self) {
        guard !divisor.isZero else { throw .zeroDivisor }
        let result = storage.divided(by: divisor.storage)
        return (
            Self(storage: result.quotient, negative: isNegative != divisor.isNegative),
            Self(storage: result.remainder, negative: isNegative)
        )
    }

    public static func gcd(_ lhs: Self, _ rhs: Self) -> Self {
        Self(storage: Natural.gcd(lhs.storage, rhs.storage), negative: false)
    }

    public func root(_ degree: Int) -> Self? {
        guard degree > 0, !isNegative || degree % 2 == 1,
            let root = storage.root(degree)
        else { return nil }
        return Self(storage: root, negative: isNegative)
    }
}

extension Integer {

    public func approximation<Scalar: BinaryFloatingPoint>(as type: Scalar.Type) -> Scalar {
        let value = scaledApproximation(as: type)
        return Scalar(
            sign: isNegative ? .minus : .plus,
            exponent: Scalar.Exponent(clamping: value.exponent),
            significand: value.significand.magnitude
        )
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
        (last..<width).reversed().forEach { index in
            if bit(at: index) { significand += weight }
            weight /= 2
        }
        if last > 0, bit(at: last - 1) {
            let guardIndex = last - 1
            let wordIndex = guardIndex / 32
            let mask = (UInt32(1) << (guardIndex % 32)) - 1
            let sticky =
                storage.words[..<wordIndex].contains { $0 != 0 }
                || storage.words[wordIndex] & mask != 0
            if sticky || bit(at: last) { significand = significand.nextUp }
        }
        return (isNegative ? -significand : significand, width - 1)
    }
}

extension Integer {
    public init<T: Swift::BinaryInteger>(_ value: T) {
        var magnitude = value.magnitude
        var words: [UInt32] = []
        while magnitude != 0 {
            words.append(UInt32(truncatingIfNeeded: magnitude))
            magnitude >>= 32
        }
        self.init(storage: Natural(words: words), negative: value < 0)
    }

    public func exactly<T: Swift::FixedWidthInteger>(_ type: T.Type) -> T? {

        T(description, radix: 10)
    }
}

#if !hasFeature(Embedded)
    extension Integer: Swift::Codable {
        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            let text = try container.decode(String.self)
            guard let value = Self(text) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Expected a base-ten integer string")
            }
            self = value
        }
        public func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(description)
        }
    }
#endif

extension Integer: Swift::Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.isNegative != rhs.isNegative { return lhs.isNegative }
        return lhs.isNegative ? rhs.storage < lhs.storage : lhs.storage < rhs.storage
    }
}

extension Integer: Swift::CustomStringConvertible {
    public var description: String { (isNegative ? "-" : "") + storage.decimal }
}

extension Integer {
    public var approximation: Double { approximation(as: Double.self) }

    public var scaledApproximation: (significand: Double, exponent: Int) {
        scaledApproximation(as: Double.self)
    }
}

extension Integer: Swift::ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Swift::StaticBigInt) {
        let negative = value.signum() < 0
        var words: [UInt32] = []
        (0..<((value.bitWidth + UInt.bitWidth - 1) / UInt.bitWidth)).forEach { index in
            let word = negative ? ~value[index] : value[index]
            for offset in stride(from: 0, to: UInt.bitWidth, by: 32) {
                words.append(UInt32(truncatingIfNeeded: word >> offset))
            }
        }
        var magnitude = Natural(words: words)
        if negative { magnitude += Natural(1) }
        self.init(storage: magnitude, negative: negative)
    }
}

extension Integer: Swift::LosslessStringConvertible {

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

extension Integer {

    public static func lcm(_ lhs: Self, _ rhs: Self) -> Self {
        guard !lhs.isZero, !rhs.isZero else { return .zero }
        let divisor = gcd(lhs, rhs)
        let quotient = lhs.storage.divided(by: divisor.storage).quotient
        return Self(storage: quotient * rhs.storage, negative: false)
    }

    public static func gcd<T: Swift::BinaryInteger>(_ lhs: T, _ rhs: T) -> Self {
        gcd(Self(lhs), Self(rhs))
    }

    public static func lcm<T: Swift::BinaryInteger>(_ lhs: T, _ rhs: T) -> Self {
        lcm(Self(lhs), Self(rhs))
    }
}
