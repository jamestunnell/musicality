require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe Parsing::NonnegativeIntegerParser do
  parser = Parsing::NonnegativeIntegerParser.new

  ["1","50","05","502530","0"].each do |str|
    it "should parse '#{str}'" do
      parser.parse(str).should_not be nil
    end
  end
end
