module Musicality
  class NonZeroError < StandardError; end
  class NegativeError < StandardError; end
  class NonPositiveError < StandardError; end
  class NonIntegerError < StandardError; end
  class NonRationalError < StandardError; end
  class NonIncreasingError < StandardError; end
  class DecreasingError < StandardError; end
  class NotValidError < StandardError; end
  class DomainError < StandardError; end
  class EmptyError < StandardError; end
  class DurationMismatchError < StandardError; end

end