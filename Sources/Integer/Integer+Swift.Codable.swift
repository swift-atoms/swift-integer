#if !hasFeature(Embedded)
extension Integer: Swift.Codable {
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
