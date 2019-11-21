module Musicality

# to use, include Parseable and define PARSER constant that has #parse method.
module Parseable
  DEFAULT_SPLIT_PATTERN = " "

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def parse str
      parser = self.const_get(:PARSER)
      node = parser.parse(str)
      raise ParseError, "Failed to parse #{str}" if node.nil?

      node.send(self.const_get(:CONVERSION_METHOD))
    end

    def split_parse str, pattern=" "
      str.split(pattern).map {|x| parse(x) }
    end
  end
end

end
