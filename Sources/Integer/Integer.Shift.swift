public import Rounding

extension Integer {

    public struct Shift<T: BinaryInteger> {
        @usableFromInline
        let value: T

        @usableFromInline
        internal init(_ value: T) {
            self.value = value
        }
    }
}


extension Integer.Shift {

    @inlinable
    public func right(
        by count: Int,
        rounding rule: Rounding = .down
    ) throws(Rounding.Error) -> T {

        if count <= 0 { return value >> count }

        if count >= value.bitWidth {

            if value.bitWidth <= 1 {
                return try T(Int8(value).shifted.right(by: count, rounding: rule))
            }

            let shiftCount = count - (value.bitWidth - 1)
            let floor = value >> shiftCount
            let lost = value - (floor << shiftCount)
            let sticky = floor | (lost == 0 ? 0 : 1)
            return try sticky.shifted.right(by: value.bitWidth - 1, rounding: rule)
        }

        let mask = (T.Magnitude(1) << count) - 1
        let lost = T.Magnitude(truncatingIfNeeded: value) & mask
        let floor = value >> count
        let ceiling = floor + (lost == 0 ? 0 : 1)
        let half: T.Magnitude = (1 as T.Magnitude) << (count &- 1)

        switch rule {
        case .direction(.down):
            return floor

        case .direction(.up):
            return ceiling

        case .direction(.zero):
            return value > 0 ? floor : ceiling

        case .direction(.away):
            return value < 0 ? floor : ceiling

        case .nearest(.down):
            return floor + T((lost + (half - 1)) >> count)

        case .nearest(.up):
            return floor + T((lost + half) >> count)

        case .nearest(.zero):
            let round = half - (value < 0 ? 0 : 1)
            return floor + T((round + lost) >> count)

        case .nearest(.away):
            let round = half - (value > 0 ? 0 : 1)
            return floor + T((round + lost) >> count)

        case .nearest(.even):
            let round = mask >> 1 + T.Magnitude(floor & 1)
            return floor + T((round + lost) >> count)

        case .odd:
            return floor | (lost == 0 ? 0 : 1)

        case .exact:
            guard lost == 0 else { throw .inexact }
            return floor
        }
    }

    @inlinable @inline(always)
    public func right<Count: BinaryInteger>(
        by count: Count,
        rounding rule: Rounding = .down
    ) throws(Rounding.Error) -> T {
        try self.right(by: Int(clamping: count), rounding: rule)
    }
}

extension Integer.Shift: Swift.Sendable where T: Swift.Sendable {}
