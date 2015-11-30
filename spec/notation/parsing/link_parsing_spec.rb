require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Parsing::LinkParser do
  before :all do
    @parser = Parsing::LinkParser.new
  end
  
  it "should parse #{LINK_SYMBOLS[Link::Tie]}" do
    @parser.should parse(LINK_SYMBOLS[Link::Tie])
  end

  it "should parse #{LINK_SYMBOLS[Link::Glissando]} with target pitch" do
    @parser.should parse(LINK_SYMBOLS[Link::Glissando] + C3.to_s)
  end

  it "should parse #{LINK_SYMBOLS[Link::Portamento]} with target pitch" do
    @parser.should parse(LINK_SYMBOLS[Link::Portamento] + C3.to_s)
  end
end
