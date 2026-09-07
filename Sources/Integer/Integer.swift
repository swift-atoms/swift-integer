/// An exact signed integer with arbitrary precision.
/// Storage grows as needed; there is no fixed numeric minimum or maximum.
public struct Integer: Hashable, Sendable {
    internal let storage: Natural
    public let isNegative: Bool

    internal init(storage: Natural, negative: Bool) {
        self.storage = storage
        self.isNegative = !storage.isZero && negative
    }

    public static var zero: Self { Self(storage: Natural(), negative: false) }
    public static var one: Self { Self(storage: Natural(1), negative: false) }
    public var isZero: Bool { storage.isZero }
    public var absolute: Self { Self(storage: storage, negative: false) }
    public var isOdd: Bool { (storage.words.first ?? 0) & 1 != 0 }
    public var bitWidth: Int { storage.bitWidth }

    public enum Error: Swift.Error, Hashable, Sendable {
        case zeroDivisor
    }
}
