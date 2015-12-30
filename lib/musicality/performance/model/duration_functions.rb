module Musicality

module DurationFunctions
  TENUTO_DURATION = Function::Linear.new([0,0],[1,1])

  NORMAL_DURATION = Function.new(0...Float::INFINITY) do |x|
    x - Rational(1,8) * (1 - Math.exp(-1.75*x))
  end

  PORTATO_DURATION = Function.new(0...Float::INFINITY) do |x|
    x - Rational(2,8) * (1 - Math.exp(-1.75*x))
  end

  STACCATO_DURATION = Function.new(0...Float::INFINITY) do |x|
    x - Rational(3,8) * (1 - Math.exp(-1.75*x))
  end

  STACCATISSIMO_DURATION = Function.new(0...Float::INFINITY) do |x|
    x - Rational(4,8) * (1 - Math.exp(-1.75*x))
  end
end

end