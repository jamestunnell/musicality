require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Parsing::LinkParser do
  before :all do
    @parser = Parsing::LinkParser.new
  end
  
  ["=C2","|C2","~C2","/C2"].each do |str|
    it "should parse #{str}" do
      @parser.should parse(str)
    end
  end
end
