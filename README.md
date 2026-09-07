# Integer

An exact signed integer with arbitrary precision. Arithmetic has no fixed-width overflow. Machine words are an implementation detail.

Integer literals use `StaticBigInt`; base-ten strings and Codable preserve arbitrary precision. Codable encodes a decimal string. `exactly(Int64.self)` and similar conversions return nil when the destination cannot represent the value.

Division truncates toward zero, with a remainder having the dividend’s sign. Division by zero throws. `root(_:)` returns only exact integer roots.

The core has no Foundation dependency. Foundation integration is a separate target.

GCD and LCM return nonnegative exact Integers. GCD(0, 0) is zero; LCM is zero if either operand is zero. Overloads for Swift binary integers widen before taking magnitudes, including signed minima. Fixed-width output is requested explicitly with `exactly(_:)`.
