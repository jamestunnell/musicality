module Musicality

# to use, include Parseable and define PARSER constant that has #parse method.
module Parseable
  DEFAULT_SPLIT_PATTERN = " "
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def parser
      self.const_get(:PARSER)
    end
    
    def convert node
      node.send(self.const_get(:CONVERSION_METHOD))
    end
    
    def parse str
      convert(parser.parse(str))
    end
    
    def split_parse str, pattern=" "
      str.split(pattern).map {|x| convert(parser.parse(x)) }
    end  
  end  
end  

end