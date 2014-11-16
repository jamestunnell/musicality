require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe Parsing::NonnegativeRationalParser do
  parser = Parsing::NonnegativeRationalParser.new

  ["1/2","0/50","05/003","502530/1","0/1"].each do |str|
    it "should parse '#{str}'" do
      parser.parse(str).should_not be nil
    end
  end
end
