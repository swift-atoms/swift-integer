# swift-integer

Use this package when you need a signed whole number that must stay exact at any size, such as a large intermediate product, a literal wider than `Int128`, or the greatest common divisor or least common multiple of two machine integers whose result may not fit their type. Start from `Integer`. The package also lets you shift a machine integer right while choosing how the discarded bits round: call `shifted` on any `Swift.BinaryInteger`, which gives an `Integer.Shift<T>`. Use the sibling swift-numeric for fixed-width arithmetic that reports or clamps overflow, and swift-rational when the value is a fraction.

## Laws

- `Integer` arithmetic is exact and never overflows. Zero has a single representation and is never negative, so `-0` and the negation of zero equal `Integer.zero`.
- Division truncates toward zero, and the remainder takes the sign of the dividend, matching `Int`. Dividing by zero throws.
- `gcd` and `lcm` use the magnitudes of their arguments and are never negative. `gcd(0, 0)` is 0, and `lcm` with a zero argument is 0. The generic overloads widen to `Integer` before they take magnitudes, so `Int8.min` behaves as 128 and a result that does not fit the argument type is still exact.
- `root(_:)` returns only exact roots. It returns `nil` when the value is not a perfect power of that degree, when the degree is not positive, or when the degree is even and the value is negative.
- The text form is base ten: an optional leading `+` or `-`, then one or more ASCII digits, with no whitespace, separators or other numerals. Any other text does not parse. The `Codable` form is the same base-ten string, not a JSON number.
- `exactly(_:)` returns `nil` when the value lies outside the target type's range. It never truncates or clamps.
- `approximation(as:)` rounds to the nearest representable value, ties to even, and gives the same result as Swift's own integer-to-float conversion. Values too large for the format become infinity with the matching sign, and zero becomes `+0`. `scaledApproximation(as:)` rounds the same way but returns the exponent separately, so values beyond the format's range stay finite.
- `Integer.Shift<T>.right(by:rounding:)` gives the result of dividing by 2 to the power of `count` and then rounding with the chosen `Rounding`. With the default `.down` it equals `>>`. Counts at or above the bit width are well defined and round the whole value away (for example, 127 shifted by 100 rounds `.up` to 1). A negative count shifts left and ignores the rule. `.exact` throws when any set bit would be discarded. `.odd` sets the lowest bit of the result whenever bits were discarded.
