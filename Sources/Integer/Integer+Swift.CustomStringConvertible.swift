extension Integer: Swift.CustomStringConvertible {
    public var description: String { (isNegative ? "-" : "") + storage.decimal }
}
