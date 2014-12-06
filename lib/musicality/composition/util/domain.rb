module Musicality

class Domain
  attr_reader :left, :right
  def initialize left, right, include_left, include_right
    if left > right
      raise DecreasingError, "left value (#{left}) is > right value (#{right})"
    end
    
    @left, @right = left, right
    @include_left, @include_right = include_left, include_right
  end
  
  def include_left?; @include_left; end
  def include_right?; @include_right; end
  
  def to_s
    "#{include_left? ? "[" : "(" }" + "#{left},#{right}" + 
    "#{include_right? ? "]" : ")" }"
  end
  
  def exclude? x; past_left?(x) || past_right?(x); end
  def include? x; !exclude?(x); end
  
  def past_left? x
    include_left? ? x < left : x <= left
  end
  
  def past_right? x
    include_right? ? x > right : x >= right
  end
  
  def check x
    raise DomainError, "#{x} is not in the current domain #{self}" if exclude?(x)
  end
end

end
