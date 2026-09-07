extension Swift.BinaryInteger {

    @inlinable
    public var shifted: Integer.Shift<Self> {
        Integer.Shift(self)
    }
}
