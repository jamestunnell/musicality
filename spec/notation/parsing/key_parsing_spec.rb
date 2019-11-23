require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Parsing::KeyParser do
  before :all do
    @parser = Parsing::KeyParser.new
  end

  {
    "Cmaj" => Musicality::Keys::C_MAJOR,
    "F#min" => Musicality::Keys::Fs_MINOR,
    "Fmin" => Musicality::Keys::F_MINOR,
    "Bbmaj" => Musicality::Keys::Bb_MAJOR
  }.each do |str, key|
    it "should parse #{str}" do
      expect(@parser).to parse(str)
      expect(str.to_key).to eq(key)
    end
  end
end
