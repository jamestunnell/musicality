module Musicality

module Interpolation  
  # Linear interpolation
  # Given 2 sample points, interpolates a value anywhere between the two points.
  #
  # @param [Numeric] y0 First (left) y-value
  # @param [Numeric] y1 Second (right) y-value
  # @param [Numeric] x Percent distance (along the x-axis) between the two y-values
  def self.linear y0, y1, x
    raise ArgumentError, "x is not between 0.0 and 1.0" unless x.between?(0.0,1.0)
    return y0 + x * (y1 - y0)
  end
end

end
