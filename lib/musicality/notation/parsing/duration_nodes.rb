module Musicality
module Parsing
  class NumDenNode < Treetop::Runtime::SyntaxNode
    def to_r
      text_value.to_r
    end
  end

  class NumOnlyNode < Treetop::Runtime::SyntaxNode
    def to_r
      Rational(numerator.text_value.to_i,1)
    end
  end
  
  class DenOnlyNode < Treetop::Runtime::SyntaxNode
    def to_r
      Rational(1,denominator.text_value.to_i)
    end
  end
end
end