extension Integer: Swift.Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.isNegative != rhs.isNegative { return lhs.isNegative }
        return lhs.isNegative ? rhs.storage < lhs.storage : lhs.storage < rhs.storage
    }
}
