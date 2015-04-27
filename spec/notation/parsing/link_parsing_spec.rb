require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Parsing::LinkParser do
  before :all do
    @parser = Parsing::LinkParser.new
  end
  
  it "should parse #{LINK_SYMBOLS[Links::TIE]}" do
    @parser.should parse(LINK_SYMBOLS[Links::TIE])
  end

  it "should parse #{LINK_SYMBOLS[Links::GLISSANDO]} with target pitch" do
    @parser.should parse(LINK_SYMBOLS[Links::GLISSANDO] + C3.to_s)
  end

  it "should parse #{LINK_SYMBOLS[Links::PORTAMENTO]} with target pitch" do
    @parser.should parse(LINK_SYMBOLS[Links::GLISSANDO] + C3.to_s)
  end
end
