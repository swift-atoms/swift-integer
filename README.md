# Integer

An exact signed integer with arbitrary precision. Arithmetic has no fixed-width overflow. Machine words are an implementation detail.

Integer literals use `StaticBigInt`; base-ten strings and Codable preserve arbitrary precision. Codable encodes a decimal string. `exactly(Int64.self)` and similar conversions return nil when the destination cannot represent the value.

Division truncates toward zero, with a remainder having the dividend’s sign. Division by zero throws. `root(_:)` returns only exact integer roots.

The core has no Foundation dependency. Foundation integration is a separate target.
